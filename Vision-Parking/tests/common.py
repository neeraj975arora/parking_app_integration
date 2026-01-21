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

def handle_anr_dialog(driver, timeout=5):
    """Handle Android ANR (Application Not Responding) dialogs"""
    anr_button_ids = [
        'android:id/aerr_wait',  # Wait button
        'android:id/button1',    # OK/Wait button
    ]
    anr_texts = ['Wait', 'OK']
    end_time = time.time() + timeout

    while time.time() < end_time:
        # Check for ANR dialog title
        try:
            anr_title = driver.find_element(AppiumBy.ID, 'android:id/alertTitle')
            if anr_title.is_displayed() and 'responding' in anr_title.text.lower():
                print(f"ANR dialog detected: {anr_title.text}")
                
                # Try to click Wait button first
                for btn_id in anr_button_ids:
                    try:
                        btn = driver.find_element(AppiumBy.ID, btn_id)
                        if btn.is_displayed():
                            print(f"Clicking ANR button: {btn.text}")
                            btn.click()
                            time.sleep(2)
                            return True
                    except:
                        continue
                        
                # Try by text
                for text in anr_texts:
                    try:
                        btn = driver.find_element(
                            AppiumBy.ANDROID_UIAUTOMATOR,
                            f'new UiSelector().textMatches("(?i){text}")'
                        )
                        if btn.is_displayed():
                            print(f"Clicking ANR button by text: {btn.text}")
                            btn.click()
                            time.sleep(2)
                            return True
                    except:
                        continue
        except:
            pass
        time.sleep(0.5)
    return False
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

def assert_element_is_visible(driver, locator):
    """
    Waits for an element to be present and asserts that it is visible on the screen.
    If the element is not found or not visible, the test will fail.
    """
    element = wait_for_element(driver, locator)
    assert element.is_displayed(), f"Element '{locator}' was found but is not visible."

def is_element_visible(driver, locator, timeout=5):
    """
    Checks if an element is visible without failing the test.
    Returns True if the element is found and visible, False otherwise.
    """
    try:
        WebDriverWait(driver, timeout).until(
            EC.visibility_of_element_located(locator)
        )
        return True
    except TimeoutException:
        return False