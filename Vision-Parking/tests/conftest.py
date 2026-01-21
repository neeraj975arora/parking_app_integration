import pytest
from appium import webdriver
from appium.options.android import UiAutomator2Options

@pytest.fixture(scope="function")
def driver():
    options = UiAutomator2Options()
    options.platform_name = 'Android'
    options.automation_name = 'UiAutomator2'
    options.device_name = 'Android Emulator'
    options.app_package = 'com.example.visionpark'
    options.app_activity = 'com.example.visionpark.activities.SplashScreenActivity'
    options.implicit_wait_timeout = 15000
    
    # Extended timeouts for CI environment
    options.set_capability('uiautomator2ServerInstallTimeout', 180000)  # 3 minutes
    options.set_capability('uiautomator2ServerLaunchTimeout', 180000)   # 3 minutes
    options.set_capability('adbExecTimeout', 120000)                    # 2 minutes
    options.set_capability('androidInstallTimeout', 120000)             # 2 minutes
    options.set_capability('newCommandTimeout', 600)                    # 10 minutes
    options.set_capability('autoGrantPermissions', True)
    options.set_capability('skipServerInstallation', False)
    options.set_capability('skipDeviceInitialization', False)
    options.set_capability('disableWindowAnimation', True)
    options.set_capability('skipLogcatCapture', True)
    
    # App launch settings to prevent ANR
    options.set_capability('appWaitActivity', '*')  # Wait for any activity
    options.set_capability('appWaitDuration', 30000)  # Wait up to 30 seconds
    options.set_capability('androidDeviceReadyTimeout', 60)  # Device ready timeout
    options.set_capability('androidInstallTimeout', 120000)  # Install timeout
    
    # Reset settings
    options.no_reset = False
    options.full_reset = False  # Don't do full reset to avoid reinstalling

    driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', options=options)
    
    # Give the app extra time to start
    import time
    time.sleep(5)
    
    yield driver
    driver.quit()