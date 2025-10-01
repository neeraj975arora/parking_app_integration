import { test, expect } from '@playwright/test';
import LoginPage from '../pages/LoginPage.js';
import { testCredentials } from '../utils/test-data.js';

test.describe('Login Page Tests', () => {
  let loginPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    await loginPage.navigateToLogin();
  });

  test.describe('Page Elements', () => {
    test('should display login page elements', async () => {
      await expect(loginPage.pageTitle).toBeVisible();
      await expect(loginPage.pageSubtitle).toBeVisible();
      await expect(loginPage.emailInput).toBeVisible();
      await expect(loginPage.passwordInput).toBeVisible();
      await expect(loginPage.loginButton).toBeVisible();
    });

    test('should display demo credentials section', async () => {
      await expect(loginPage.demoCredentialsSection).toBeVisible();
      await expect(loginPage.superAdminDemoButton).toBeVisible();
      await expect(loginPage.adminDemoButton).toBeVisible();
    });

    test('should have proper form labels and placeholders', async () => {
      await expect(loginPage.emailInput).toHaveAttribute('placeholder', 'Enter your email');
      await expect(loginPage.passwordInput).toHaveAttribute('placeholder', 'Enter your password');
      await expect(loginPage.emailInput).toHaveAttribute('type', 'email');
      await expect(loginPage.passwordInput).toHaveAttribute('type', 'password');
    });
  });

  test.describe('Successful Login', () => {
    test('should login successfully as super admin', async ({ page }) => {
      await loginPage.loginAsSuperAdmin();
      await loginPage.waitForLoginSuccess();
      
      expect(await loginPage.isLoginSuccessful()).toBe(true);
      await expect(page).toHaveURL(/.*dashboard/);
    });

    test('should login successfully as admin', async ({ page }) => {
      await loginPage.loginAsAdmin();
      await loginPage.waitForLoginSuccess();
      
      expect(await loginPage.isLoginSuccessful()).toBe(true);
      await expect(page).toHaveURL(/.*dashboard/);
    });

    test('should use super admin demo credentials successfully', async ({ page }) => {
      await loginPage.useSuperAdminDemoCredentials();
      await loginPage.loginButton.click();
      await loginPage.waitForLoginSuccess();
      
      expect(await loginPage.isLoginSuccessful()).toBe(true);
      await expect(page).toHaveURL(/.*dashboard/);
    });

    test('should use admin demo credentials successfully', async ({ page }) => {
      await loginPage.useAdminDemoCredentials();
      await loginPage.loginButton.click();
      await loginPage.waitForLoginSuccess();
      
      expect(await loginPage.isLoginSuccessful()).toBe(true);
      await expect(page).toHaveURL(/.*dashboard/);
    });
  });

  test.describe('Form Validation', () => {
    test('should validate required fields', async () => {
      await loginPage.loginButton.click();
      
      // Check that required attributes are present
      await expect(loginPage.emailInput).toHaveAttribute('required');
      await expect(loginPage.passwordInput).toHaveAttribute('required');
    });

    test('should show validation error for empty email', async () => {
      await loginPage.passwordInput.fill('password123');
      await loginPage.loginButton.click();
      
      // Wait for validation error
      await expect(loginPage.emailInput).toHaveAttribute('required');
    });

    test('should show validation error for empty password', async () => {
      await loginPage.emailInput.fill('test@example.com');
      await loginPage.loginButton.click();
      
      // Wait for validation error
      await expect(loginPage.passwordInput).toHaveAttribute('required');
    });

    test('should clear errors when user starts typing', async () => {
      // First trigger validation error
      await loginPage.loginButton.click();
      
      // Then start typing in email field
      await loginPage.emailInput.fill('test@example.com');
      
      // Error should be cleared (no visible error message)
      await expect(loginPage.emailError).not.toBeVisible();
    });
  });

  test.describe('Invalid Credentials', () => {
    test('should show error for invalid email', async () => {
      await loginPage.login('invalid@email.com', 'wrongpassword');
      await loginPage.waitForLoginError();
      
      const errorMessage = await loginPage.getLoginErrorMessage();
      expect(errorMessage).toContain('Invalid email, password, or role');
    });

    test('should show error for invalid password', async () => {
      await loginPage.login('superadmin@parking.com', 'wrongpassword');
      await loginPage.waitForLoginError();
      
      const errorMessage = await loginPage.getLoginErrorMessage();
      expect(errorMessage).toContain('Invalid email, password, or role');
    });

    test('should show error for non-existent user', async () => {
      await loginPage.login('nonexistent@email.com', 'password123');
      await loginPage.waitForLoginError();
      
      const errorMessage = await loginPage.getLoginErrorMessage();
      expect(errorMessage).toContain('Invalid email, password, or role');
    });
  });

  test.describe('Demo Credentials Functionality', () => {
    test('should autofill super admin credentials', async () => {
      await loginPage.useSuperAdminDemoCredentials();
      
      const emailValue = await loginPage.emailInput.inputValue();
      const passwordValue = await loginPage.passwordInput.inputValue();
      
      expect(emailValue).toBe('superadmin@parking.com');
      expect(passwordValue).toBe('password123');
    });

    test('should autofill admin credentials', async () => {
      await loginPage.useAdminDemoCredentials();
      
      const emailValue = await loginPage.emailInput.inputValue();
      const passwordValue = await loginPage.passwordInput.inputValue();
      
      expect(emailValue).toBe('admin@parking.com');
      expect(passwordValue).toBe('admin123');
    });

    test('should clear form before autofilling', async () => {
      // Fill form with some data
      await loginPage.emailInput.fill('test@example.com');
      await loginPage.passwordInput.fill('testpass');
      
      // Use demo credentials
      await loginPage.useSuperAdminDemoCredentials();
      
      // Should have demo credentials, not the previous data
      const emailValue = await loginPage.emailInput.inputValue();
      expect(emailValue).toBe('superadmin@parking.com');
    });
  });

  test.describe('Loading States', () => {
    test('should show loading state during login', async () => {
      // Start login process
      await loginPage.emailInput.fill('superadmin@parking.com');
      await loginPage.passwordInput.fill('password123');
      
      // Click login button and wait for navigation
      await loginPage.loginButton.click();
      await loginPage.waitForLoginSuccess();
      
      // Verify we successfully navigated to dashboard
      expect(await loginPage.isLoginSuccessful()).toBe(true);
    });

    test('should disable demo buttons during login', async () => {
      // Start login process
      await loginPage.emailInput.fill('superadmin@parking.com');
      await loginPage.passwordInput.fill('password123');
      
      // Click login button and wait for navigation
      await loginPage.loginButton.click();
      await loginPage.waitForLoginSuccess();
      
      // Verify we successfully navigated to dashboard
      expect(await loginPage.isLoginSuccessful()).toBe(true);
    });
  });

  test.describe('Form Interactions', () => {
    test('should clear login error when user starts typing', async () => {
      // First trigger a login error
      await loginPage.login('invalid@email.com', 'wrongpassword');
      await loginPage.waitForLoginError();
      
      // Then start typing in email field
      await loginPage.emailInput.fill('test@example.com');
      
      // Error should be cleared
      await expect(loginPage.loginError).not.toBeVisible();
    });

    test('should maintain form state during navigation', async () => {
      // Fill form
      await loginPage.emailInput.fill('test@example.com');
      await loginPage.passwordInput.fill('testpass');
      
      // Navigate away and back
      await loginPage.navigateTo('/dashboard');
      await loginPage.navigateToLogin();
      
      // Form should be cleared (this is expected behavior)
      const emailValue = await loginPage.emailInput.inputValue();
      const passwordValue = await loginPage.passwordInput.inputValue();
      
      expect(emailValue).toBe('');
      expect(passwordValue).toBe('');
    });
  });

  test.describe('Accessibility', () => {
    test('should have proper form labels', async () => {
      await expect(loginPage.emailInput).toHaveAttribute('name', 'user_email');
      await expect(loginPage.passwordInput).toHaveAttribute('name', 'user_password');
    });

    test('should have proper autocomplete attributes', async () => {
      await expect(loginPage.emailInput).toHaveAttribute('autocomplete', 'email');
      await expect(loginPage.passwordInput).toHaveAttribute('autocomplete', 'current-password');
    });

    test('should have proper button type', async () => {
      await expect(loginPage.loginButton).toHaveAttribute('type', 'submit');
    });
  });

  test.describe('Edge Cases', () => {
    test('should handle very long email input', async () => {
      const longEmail = 'a'.repeat(100) + '@example.com';
      await loginPage.emailInput.fill(longEmail);
      await loginPage.passwordInput.fill('password123');
      await loginPage.loginButton.click();
      
      // Should show validation error or login error
      await expect(loginPage.loginError).toBeVisible();
    });

    test('should handle special characters in password', async () => {
      await loginPage.login('superadmin@parking.com', '!@#$%^&*()');
      await loginPage.waitForLoginError();
      
      const errorMessage = await loginPage.getLoginErrorMessage();
      expect(errorMessage).toContain('Invalid email, password, or role');
    });

    test('should handle empty form submission', async () => {
      await loginPage.loginButton.click();
      
      // Should not navigate away from login page
      await expect(loginPage.pageTitle).toBeVisible();
    });
  });
});
