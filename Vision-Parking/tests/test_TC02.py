from .common import wait_for_element, fill_registration_form, assert_validation_message
from .auth_helpers import generate_unique_email, generate_unique_phone, register_user
from appium.webdriver.common.appiumby import AppiumBy

from tests.constants import (REGISTER_NAME, REGISTER_PASSWORD,
                             REGISTER_PHONE, REGISTER_ADDRESS, REGISTER_EMAIL)


def test_registration_after_app_launch(driver):
    wait_for_element(driver, (AppiumBy.ID, 'btnGetStarted')).click()
    wait_for_element(driver, (AppiumBy.ID, 'tvRegister')).click()

    register_user(driver, REGISTER_NAME, REGISTER_EMAIL,
                  REGISTER_PASSWORD, REGISTER_PHONE, REGISTER_ADDRESS)
