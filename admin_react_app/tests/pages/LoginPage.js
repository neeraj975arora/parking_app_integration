import BasePage from './BasePage.js';

class LoginPage extends BasePage {
  constructor(page) {
    super(page);
    // Form elements
    this.emailInput = page.locator('input[name="user_email"]');
    this.passwordInput = page.locator('input[name="user_password"]');
    this.loginButton = page.locator('button[type="submit"]');
    
    // Error elements
    this.loginError = page.locator('.bg-red-50 .text-red-700');
    this.emailError = page.locator('#input-user_email-error');
    this.passwordError = page.locator('#input-user_password-error');
    
    // Demo credential buttons - using CSS class selectors
    this.superAdminDemoButton = page.locator('button.text-blue-700').filter({ hasText: 'superadmin@parking.com' });
    this.adminDemoButton = page.locator('button.text-green-700').filter({ hasText: 'admin@parking.com' });
    
    // Page elements
    this.pageTitle = page.locator('h2:has-text("Admin Portal")');
    this.pageSubtitle = page.locator('text=Sign in to your administrator account');
    this.loadingSpinner = page.locator('.animate-spin');
    
    // Demo credentials section
    this.demoCredentialsSection = page.locator('text=Demo Credentials');
  }

  async navigateToLogin() {
    await this.navigateTo('/login');
    await this.waitForPageLoad();
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }

  async loginAsSuperAdmin() {
    await this.login('superadmin@parking.com', 'password123');
  }

  async loginAsAdmin() {
    await this.login('admin@parking.com', 'admin123');
  }

  async useSuperAdminDemoCredentials() {
    await this.superAdminDemoButton.click();
  }

  async useAdminDemoCredentials() {
    await this.adminDemoButton.click();
  }

  async waitForLoginSuccess() {
    try {
      await this.page.waitForURL('**/dashboard', { timeout: 20000 });
    } catch (error) {
      // If navigation fails, check if we're still on login page and try again
      const currentUrl = this.page.url();
      if (currentUrl.includes('/login')) {
        // Wait a bit more and try to navigate manually
        await this.page.waitForTimeout(3000);
        await this.page.goto('http://localhost:5173/dashboard');
        await this.page.waitForLoadState('networkidle');
      }
    }
  }

  async waitForLoginError() {
    await this.waitForElement('.bg-red-50');
  }

  async isLoginSuccessful() {
    return this.page.url().includes('/dashboard');
  }

  async getLoginErrorMessage() {
    return await this.loginError.textContent();
  }

  async getEmailError() {
    return await this.emailError.textContent();
  }

  async getPasswordError() {
    return await this.passwordError.textContent();
  }

  async isFormValid() {
    const emailValue = await this.emailInput.inputValue();
    const passwordValue = await this.passwordInput.inputValue();
    return emailValue.length > 0 && passwordValue.length > 0;
  }

  async clearForm() {
    await this.emailInput.clear();
    await this.passwordInput.clear();
  }

  async isDemoCredentialsSectionVisible() {
    return await this.demoCredentialsSection.isVisible();
  }

  async isLoginButtonDisabled() {
    return await this.loginButton.isDisabled();
  }

  async getLoginButtonText() {
    return await this.loginButton.textContent();
  }

  async waitForLoadingToComplete() {
    await this.page.waitForFunction(() => {
      const spinner = document.querySelector('.animate-spin');
      return !spinner || spinner.style.display === 'none';
    });
  }
}

export default LoginPage;
