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
    options.implicit_wait_timeout = 10000
    options.set_capability('uiautomator2ServerInstallTimeout', 120000)
    options.set_capability('newCommandTimeout', 300)
    options.set_capability('autoGrantPermissions', True)
    options.no_reset = False

    driver = webdriver.Remote('http://127.0.0.1:4723/wd/hub', options=options)
    yield driver
    driver.quit()
