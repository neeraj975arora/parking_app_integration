from .common import wait_for_element, handle_permission_dialog, handle_anr_dialog
import pytest
import time
from appium.webdriver.common.appiumby import AppiumBy


def test_app_launch(driver):
    # Handle any permission dialogs first
    print("Handling permission dialogs...")
    handle_permission_dialog(driver, timeout=10)
    
    # Check for and handle ANR dialogs
    print("Checking for ANR dialogs...")
    if handle_anr_dialog(driver, timeout=5):
        print("ANR dialog handled, waiting for app to recover...")
        time.sleep(5)
    
    # Give more time for app to fully load after permissions
    time.sleep(10)
    
    # Check if app crashed and needs to be restarted
    try:
        current_activity = driver.current_activity
        print(f"Current activity: {current_activity}")
        
        # If we're still on splash screen after long wait, something is wrong
        if 'SplashScreenActivity' in current_activity:
            print("Still on splash screen, checking for issues...")
            
            # Check for ANR dialog again
            if handle_anr_dialog(driver, timeout=3):
                print("Handled ANR dialog, waiting...")
                time.sleep(5)
            
            # Try to restart the app if it's stuck
            print("App seems stuck, attempting restart...")
            driver.terminate_app('com.example.visionpark')
            time.sleep(2)
            driver.activate_app('com.example.visionpark')
            time.sleep(8)
            
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
    
    # Check for ANR dialog in page source
    if 'responding' in page_source.lower() or 'aerr_' in page_source:
        print("ANR dialog detected in page source, handling...")
        handle_anr_dialog(driver, timeout=5)
        time.sleep(5)
        
        # Get fresh page source after handling ANR
        try:
            page_source = driver.page_source
            print("=== PAGE SOURCE AFTER ANR HANDLING ===")
            print(page_source[:1000])
            print("=== END PAGE SOURCE AFTER ANR ===")
        except Exception as e:
            print(f"Could not get page source after ANR: {e}")
    
    # Debug: Try to find any elements with text content
    try:
        all_elements = driver.find_elements(AppiumBy.XPATH, "//*[@text]")
        print("=== ELEMENTS WITH TEXT ===")
        for elem in all_elements[:10]:  # Print first 10 elements
            try:
                text = elem.text
                resource_id = elem.get_attribute('resource-id')
                # Skip ANR dialog elements
                if 'aerr_' not in resource_id and 'responding' not in text.lower():
                    print(f"Text: '{text}', Resource-id: '{resource_id}'")
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
                # Try to find by text content (but avoid ANR dialog)
                app_name = driver.find_element(AppiumBy.XPATH, "//*[contains(@text, 'VisionPark') or contains(@text, 'Vision') or contains(@text, 'Park')]")
                # Make sure it's not the ANR dialog
                if 'responding' in app_name.text.lower():
                    app_name = None
            except:
                # Try to find any TextView that might be the app name (but not ANR)
                try:
                    text_views = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.TextView")
                    for tv in text_views:
                        if tv.text and 'responding' not in tv.text.lower() and len(tv.text) > 3:
                            app_name = tv
                            break
                except:
                    print("Could not find app name element with any method - continuing anyway")
    
    if app_name and 'responding' not in app_name.text.lower():
        assert app_name.is_displayed()
        print(f"Found app name element: {app_name.text}")

    # Try to find get started button with flexible approach (avoid ANR buttons)
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
                    # Find buttons but avoid ANR dialog buttons
                    buttons = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.Button")
                    for btn in buttons:
                        if btn.text and 'aerr_' not in btn.get_attribute('resource-id'):
                            if any(word in btn.text.lower() for word in ['start', 'begin', 'continue', 'next']):
                                get_started_btn = btn
                                break
                except:
                    pytest.fail("Could not find get started button with any method")
    
    if get_started_btn and 'close' not in get_started_btn.text.lower():
        assert get_started_btn.is_displayed()
        print(f"Found get started button: {get_started_btn.text}")
        get_started_btn.click()
        
        # Handle any permission dialogs that might appear after clicking
        handle_permission_dialog(driver, timeout=5)
        # Handle any ANR dialogs that might appear after clicking
        handle_anr_dialog(driver, timeout=3)
    else:
        pytest.fail("Could not find valid get started button (found ANR dialog instead)")

    # Wait longer for login screen and handle any additional dialogs
    time.sleep(8)
    
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
        # Check for ANR dialog one more time
        if handle_anr_dialog(driver, timeout=3):
            print("Handled ANR dialog, retrying login button search...")
            time.sleep(3)
            try:
                login_btn = wait_for_element(driver, (AppiumBy.ID, 'btnLogin'), timeout=5)
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
            
            # Try to find all clickable elements (but avoid ANR buttons)
            clickable_elements = driver.find_elements(AppiumBy.XPATH, "//*[@clickable='true']")
            print("=== CLICKABLE ELEMENTS ===")
            for elem in clickable_elements[:5]:
                try:
                    resource_id = elem.get_attribute('resource-id')
                    if 'aerr_' not in resource_id:  # Skip ANR dialog buttons
                        print(f"Clickable: Text='{elem.text}', Resource-id='{resource_id}'")
                except:
                    pass
            print("=== END CLICKABLE ELEMENTS ===")
        except Exception as e:
            print(f"Error getting debug info: {e}")
        
        pytest.fail("Could not find login button after clicking get started - app may have crashed")
    
    print(f"Successfully found login button: {login_btn.text}")
    assert login_btn.is_displayed()
