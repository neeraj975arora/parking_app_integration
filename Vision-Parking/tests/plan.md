# Test Plan – VisionPark App

## Overview
This test plan outlines the end-to-end (E2E) test cases implemented using Appium + Pytest for the VisionPark Android app. It includes tests for app launch, user registration, login, and form validations.

---

## Test Environment

- **Platform:** Android Emulator
- **Automation Tool:** Appium
- **Test Framework:** Pytest
- **App Package:** `com.example.visionpark`
- **App Activity:** `com.example.visionpark.activities.SplashScreenActivity`
- **Appium Server URL:** `http://127.0.0.1:4723/wd/hub`

---

## Test Scenarios

| Test Case ID | Test Name                                | Description                                                                 | Precondition             |
|--------------|-------------------------------------------|-----------------------------------------------------------------------------|--------------------------|
| TC01         | `test_app_launch`                         | Verify app splash screen loads and "Get Started" button works              | App installed            |
| TC02         | `test_registration_after_app_launch`      | Navigate to registration and submit a new valid user                       | App launched             |
| TC03         | `test_login_with_registered_credentials`    | Login using known test credentials                                         | Existing account         |
| TC04         | `test_registration_empty_email`            | Test form validation for empty email       | -                        |
| TC05         | `test_registration_invalid_email`             | Test form validation for invalid email                       | -     |
| TC06         | `test_registration_short_password`             | Test form validation for short password                      | -    |
| TC07         | `test_duplicate_registration`             | Attempt to register with an already registered email                       | Existing account     |

---

## Test Data

| Field     | Sample Value                     |
|-----------|----------------------------------|
| Name      | New_User_2                       |
| Email     | `testuser_<random>@example.com`  |
| Password  | new_secret123                    |
| Phone     | `9<random_9_digits>`             |
| Address   | 456 New St                       |

---

## Execution

- Run with:
  ```bash
  pytest --html=report.html --self-contained-html
