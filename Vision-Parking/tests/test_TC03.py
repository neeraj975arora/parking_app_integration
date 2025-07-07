from .common import wait_for_element, fill_registration_form, assert_validation_message
from .auth_helpers import login, generate_unique_email, generate_unique_phone, register_user
from appium.webdriver.common.appiumby import AppiumBy
from tests.constants import (REGISTER_EMAIL, REGISTER_PASSWORD)


def test_login_with_provided_credentials(driver):
    wait_for_element(driver, (AppiumBy.ID, 'btnGetStarted')).click()
    login(driver, REGISTER_EMAIL, REGISTER_PASSWORD)
