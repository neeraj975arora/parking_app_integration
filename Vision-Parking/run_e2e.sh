#!/bin/bash
set -e

# === Global config ===
export APPIUM_LOG_FILE="/tmp/appium.log"

cleanup_logcat() {
  echo "Capturing final logcat output..."
  ${ANDROID_SDK_ROOT}/platform-tools/adb logcat -d > /tmp/logcat.txt 2>&1 || touch /tmp/logcat.txt
}
trap cleanup_logcat EXIT

cd "$(dirname "$0")"

chmod +x gradlew

echo "Assembling debug APK..."
./gradlew assembleDebug -p app

echo "Waiting for Android device..."
${ANDROID_SDK_ROOT}/platform-tools/adb wait-for-device

echo "Polling for emulator boot completion..."
for i in $(seq 1 30); do
  BOOT_STATUS=$(${ANDROID_SDK_ROOT}/platform-tools/adb shell getprop sys.boot_completed | tr -d '\r')
  if [[ "$BOOT_STATUS" == "1" ]]; then
    echo "✅ Emulator boot completed"
    break
  fi
  echo "⏳ Waiting for emulator to boot ($i/30)..."
  sleep 5
done
if [[ "$BOOT_STATUS" != "1" ]]; then
  echo "❌ Emulator did not boot in time."
  exit 1
fi

echo "Waiting for package manager service..."
for i in $(seq 1 30); do
  if ${ANDROID_SDK_ROOT}/platform-tools/adb shell service check package | grep -q "found"; then
    echo "✅ Package manager service is available"
    break
  fi
  echo "⏳ Waiting for package manager service ($i/30)..."
  sleep 5
done

echo "=== ADB diagnostics ==="
${ANDROID_SDK_ROOT}/platform-tools/adb devices
${ANDROID_SDK_ROOT}/platform-tools/adb shell getprop
${ANDROID_SDK_ROOT}/platform-tools/adb shell df -h
${ANDROID_SDK_ROOT}/platform-tools/adb shell uptime
${ANDROID_SDK_ROOT}/platform-tools/adb shell top -n 1

echo "Sleeping 10 seconds before install..."
sleep 10

echo "Installing app-debug.apk with retries..."
INSTALL_SUCCESS=0
for i in $(seq 1 5); do
  if ${ANDROID_SDK_ROOT}/platform-tools/adb install -r app/build/outputs/apk/debug/app-debug.apk; then
    INSTALL_SUCCESS=1
    echo "✅ APK installed successfully on attempt $i"
    break
  else
    echo "❌ APK install failed on attempt $i, retrying in 30s..."
    sleep 30
  fi
done
if [ $INSTALL_SUCCESS -ne 1 ]; then
  echo "APK install failed after 5 attempts"
  exit 1
fi

echo "Installing Appium globally..."
npm install -g appium

echo "Installing Appium UiAutomator2 driver..."
appium driver install uiautomator2

echo "Appium version:"
appium -v

echo "Starting Appium server in background with debug logging..."
nohup appium --base-path /wd/hub --log "$APPIUM_LOG_FILE" --log-level debug &
APPIUM_PID=$!

echo "Waiting for Appium server to be ready (up to 60s)..."
for i in {1..60}; do
  if nc -z 127.0.0.1 4723; then
    echo "✅ Appium is up!"
    break
  fi
  sleep 1
done

if ! nc -z 127.0.0.1 4723; then
  echo "❌ Appium did not start in time!"
  echo "Printing Appium log for immediate debugging:"
  cat "$APPIUM_LOG_FILE"
  exit 1
fi

if [ "$(basename "$PWD")" != "Vision-Parking" ]; then
  cd Vision-Parking || { echo "Failed to change directory to Vision-Parking"; exit 1; }
fi

export TEST_REPORT_FILE=tests/report.html

echo "Running pytest E2E tests..."
pytest -q --disable-warnings --html="$TEST_REPORT_FILE" --self-contained-html
PYTEST_EXIT=$?

if [ ! -f "$TEST_REPORT_FILE" ]; then
  echo "❌ Test report not generated, marking as failed."
  exit 1
fi

# New logic: If pytest passed, exit successfully immediately
if [ $PYTEST_EXIT -eq 0 ]; then
  echo "✅ All Pytest E2E tests passed. Exiting successfully."
  # Stop Appium cleanly
  echo "Stopping Appium (PID=$APPIUM_PID)..."
  kill $APPIUM_PID || true
  wait $APPIUM_PID 2>/dev/null || true
  # Do NOT kill emulator or adb here. Let the android-emulator-runner action handle it.
  exit 0
else
  # If pytest failed, proceed to capture logs for debugging
  echo "❌ Pytest exited with code $PYTEST_EXIT. This indicates test failures or errors. Collecting logs for debugging."
  # Add a 1-minute (60-second) delay before killing Appium to ensure logs are flushed
  echo "Waiting 60 seconds for Appium to flush all logs and complete operations before stopping..."
  sleep 60

  echo "Stopping Appium (PID=$APPIUM_PID)..."
  kill $APPIUM_PID || true
  wait $APPIUM_PID 2>/dev/null || true
  # Do NOT kill emulator or adb here. Let the android-emulator-runner action handle it.

  # Final log check
  if [ -n "$APPIUM_LOG_FILE" ] && [ -f "$APPIUM_LOG_FILE" ]; then
    echo "✅ Appium log exists: $APPIUM_LOG_FILE"
  else
    echo "⚠️ Appium log not found or empty!"
    touch "$APPIUM_LOG_FILE"
  fi

  # Exit with the pytest failure status
  exit $PYTEST_EXIT
fi