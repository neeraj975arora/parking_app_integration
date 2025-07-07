from .common import wait_for_element, fill_registration_form, assert_validation_message
from .auth_helpers import generate_unique_email, generate_unique_phone, register_user
from appium.webdriver.common.appiumby import AppiumBy

from tests.constants import (
    REGISTER_NAME, REGISTER_PASSWORD, REGISTER_PHONE, REGISTER_ADDRESS)


def test_registration_invalid_email(driver):
    wait_for_element(driver, (AppiumBy.ID, 'btnGetStarted')).click()
    wait_for_element(driver, (AppiumBy.ID, 'tvRegister')).click()

    # Invalid email
    fill_registration_form(driver, REGISTER_NAME, "InvalidEmail",
                           REGISTER_PASSWORD, REGISTER_PHONE, REGISTER_ADDRESS)
    wait_for_element(driver, (AppiumBy.ID, 'btnRegister')).click()
    assert_validation_message(
        driver, ["Please enter a valid email", "valid email", "invalid email", "@"])
