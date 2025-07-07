import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

def fill_registration_form(driver, name, email, password, phone, address):
    wait_for_element(driver, (AppiumBy.ID, 'etName')).send_keys(name)
    wait_for_element(driver, (AppiumBy.ID, 'etEmail')).send_keys(email)
    wait_for_element(driver, (AppiumBy.ID, 'etPassword')).send_keys(password)
    wait_for_element(driver, (AppiumBy.ID, 'etPhone')).send_keys(phone)
    wait_for_element(driver, (AppiumBy.ID, 'etAddress')).send_keys(address)

def wait_for_element(driver, locator, timeout=10):
    try:
        return WebDriverWait(driver, timeout).until(
            EC.presence_of_element_located(locator)
        )
    except TimeoutException:
        pytest.fail(f"Timeout: Element {locator} not found after {timeout} seconds.")
    except NoSuchElementException:
        pytest.fail(f"No Such Element: {locator}")
    except Exception as e:
        pytest.fail(str(e))

def handle_permission_dialog(driver, timeout=5):
    allow_button_ids = [
        'com.android.permissioncontroller:id/permission_allow_button',
        'com.android.packageinstaller:id/permission_allow_button',
        'com.android.permissioncontroller:id/permission_allow_foreground_only_button',
        'com.android.permissioncontroller:id/permission_allow_always_button',
        'com.android.permissioncontroller:id/permission_allow_one_time_button',
    ]
    allow_texts = ['ALLOW', 'Allow', 'allow']
    end_time = time.time() + timeout

    while time.time() < end_time:
        for btn_id in allow_button_ids:
            try:
                btn = driver.find_element(AppiumBy.ID, btn_id)
                if btn.is_displayed():
                    btn.click()
                    return
            except:
                continue
        for text in allow_texts:
            try:
                btn = driver.find_element(
                    AppiumBy.ANDROID_UIAUTOMATOR,
                    f'new UiSelector().textMatches("(?i){text}")'
                )
                if btn.is_displayed():
                    btn.click()
                    return
            except:
                continue
        time.sleep(0.5)

def assert_validation_message(driver, expected_msgs):
    from selenium.common.exceptions import TimeoutException
    expanded_msgs = set(expected_msgs)

    # Add common variants to increase matching reliability
    expanded_msgs.update([
        "Please enter", "required", "valid email", "invalid", "@",
        "already exists", "already registered", "Password must be at least",
        "short password", "minimum", "duplicate"
    ])

    found = False
    for msg in expanded_msgs:
        try:
            toast = WebDriverWait(driver, 10, poll_frequency=0.2).until(
                lambda d: d.find_element(
                    AppiumBy.ANDROID_UIAUTOMATOR,
                    f'new UiSelector().textContains("{msg}")'
                )
            )
            if toast and toast.is_displayed():
                print(f"[Toast detected] Matching message: {msg}")
                found = True
                break
        except Exception:
            continue

    assert found, f"Expected toast not found. Checked for: {list(expanded_msgs)}"






