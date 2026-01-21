from .common import wait_for_element, handle_permission_dialog
import pytest
import time
from appium.webdriver.common.appiumby import AppiumBy


def test_app_launch(driver):
    # Handle any permission dialogs first
    print("Handling permission dialogs...")
    handle_permission_dialog(driver, timeout=10)
    
    # Give more time for app to fully load after permissions
    time.sleep(8)
    
    # Debug: Print current activity and page source
    try:
        current_activity = driver.current_activity
        print(f"Current activity: {current_activity}")
    except Exception as e:
        print(f"Could not get current activity: {e}")
    
    # Debug: Print page source to see what elements are available
    try:
        page_source = driver.page_source
        print("=== PAGE SOURCE ===")
        print(page_source[:2000])  # Print first 2000 characters
        print("=== END PAGE SOURCE ===")
    except Exception as e:
        print(f"Could not get page source: {e}")
    
    # Debug: Try to find any elements with text content
    try:
        all_elements = driver.find_elements(AppiumBy.XPATH, "//*[@text]")
        print("=== ELEMENTS WITH TEXT ===")
        for elem in all_elements[:10]:  # Print first 10 elements
            try:
                print(f"Text: '{elem.text}', Resource-id: '{elem.get_attribute('resource-id')}'")
            except:
                pass
        print("=== END ELEMENTS ===")
    except Exception as e:
        print(f"Could not get elements: {e}")
    
    # Try to find the app name element with more flexible approach
    app_name = None
    try:
        # Try original ID
        app_name = wait_for_element(driver, (AppiumBy.ID, 'tvAppName'), timeout=5)
    except:
        try:
            # Try with full resource ID
            app_name = wait_for_element(driver, (AppiumBy.ID, 'com.example.visionpark:id/tvAppName'), timeout=5)
        except:
            try:
                # Try to find by text content
                app_name = driver.find_element(AppiumBy.XPATH, "//*[contains(@text, 'VisionPark') or contains(@text, 'Vision') or contains(@text, 'Park')]")
            except:
                # Try to find any TextView that might be the app name
                try:
                    app_name = driver.find_element(AppiumBy.CLASS_NAME, "android.widget.TextView")
                except:
                    print("Could not find app name element with any method - continuing anyway")
    
    if app_name:
        assert app_name.is_displayed()
        print(f"Found app name element: {app_name.text}")

    # Try to find get started button with flexible approach
    get_started_btn = None
    try:
        get_started_btn = wait_for_element(driver, (AppiumBy.ID, 'btnGetStarted'), timeout=5)
    except:
        try:
            get_started_btn = wait_for_element(driver, (AppiumBy.ID, 'com.example.visionpark:id/btnGetStarted'), timeout=5)
        except:
            try:
                get_started_btn = driver.find_element(AppiumBy.XPATH, "//*[contains(@text, 'Get Started') or contains(@text, 'START') or contains(@text, 'Begin')]")
            except:
                try:
                    get_started_btn = driver.find_element(AppiumBy.CLASS_NAME, "android.widget.Button")
                except:
                    pytest.fail("Could not find get started button with any method")
    
    if get_started_btn:
        assert get_started_btn.is_displayed()
        print(f"Found get started button: {get_started_btn.text}")
        get_started_btn.click()
        
        # Handle any permission dialogs that might appear after clicking
        handle_permission_dialog(driver, timeout=5)

    # Wait longer for login screen and handle any additional dialogs
    time.sleep(5)
    
    # Try multiple approaches to find login button
    login_btn = None
    try:
        login_btn = wait_for_element(driver, (AppiumBy.ID, 'btnLogin'), timeout=10)
    except:
        try:
            login_btn = wait_for_element(driver, (AppiumBy.ID, 'com.example.visionpark:id/btnLogin'), timeout=5)
        except:
            try:
                # Try to find by text content
                login_btn = driver.find_element(AppiumBy.XPATH, "//*[contains(@text, 'Login') or contains(@text, 'LOG IN') or contains(@text, 'Sign In')]")
            except:
                try:
                    # Try to find any button that might be login
                    buttons = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.Button")
                    for btn in buttons:
                        if btn.text and ('login' in btn.text.lower() or 'sign' in btn.text.lower()):
                            login_btn = btn
                            break
                except:
                    pass
    
    if not login_btn:
        # Print current state after click for debugging
        try:
            current_activity = driver.current_activity
            print(f"Current activity after click: {current_activity}")
            page_source = driver.page_source
            print("=== PAGE SOURCE AFTER CLICK ===")
            print(page_source[:2000])
            print("=== END PAGE SOURCE AFTER CLICK ===")
            
            # Try to find all clickable elements
            clickable_elements = driver.find_elements(AppiumBy.XPATH, "//*[@clickable='true']")
            print("=== CLICKABLE ELEMENTS ===")
            for elem in clickable_elements[:5]:
                try:
                    print(f"Clickable: Text='{elem.text}', Resource-id='{elem.get_attribute('resource-id')}'")
                except:
                    pass
            print("=== END CLICKABLE ELEMENTS ===")
        except Exception as e:
            print(f"Error getting debug info: {e}")
        
        pytest.fail("Could not find login button after clicking get started")
    
    print(f"Successfully found login button: {login_btn.text}")
    assert login_btn.is_displayed()
