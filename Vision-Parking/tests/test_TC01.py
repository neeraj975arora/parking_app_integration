from .common import wait_for_element
import pytest
import time
from appium.webdriver.common.appiumby import AppiumBy


def test_app_launch(driver):
    time.sleep(2)
    app_name = wait_for_element(driver, (AppiumBy.ID, 'tvAppName'))
    assert app_name.is_displayed()

    get_started_btn = wait_for_element(driver, (AppiumBy.ID, 'btnGetStarted'))
    assert get_started_btn.is_displayed()
    get_started_btn.click()

    wait_for_element(driver, (AppiumBy.ID, 'btnLogin'))
