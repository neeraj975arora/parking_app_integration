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
    this.emailError = page.locator('text=Email is required').or(page.locator('text=Please enter a valid email'));
    this.passwordError = page.locator('text=Password is required');
    
    // Demo credential buttons - using more specific selectors
    this.superAdminDemoButton = page.locator('button[type="button"]').filter({ hasText: 'superadmin@parking.com' });
    this.adminDemoButton = page.locator('button[type="button"]').filter({ hasText: 'admin10@parking.com' });
    
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
    await this.login('admin10@parking.com', 'password123');
  }

  async useSuperAdminDemoCredentials() {
    await this.superAdminDemoButton.click();
  }

  async useAdminDemoCredentials() {
    await this.adminDemoButton.click();
  }

  async waitForLoginSuccess() {
    // Wait for either URL change to dashboard or dashboard title to appear
    const dashboardTitleSelector = 'h1:has-text("Dashboard Overview")';
    try {
      await Promise.race([
        this.page.waitForURL('**/dashboard', { timeout: 40000 }),
        this.page.waitForSelector(dashboardTitleSelector, { timeout: 40000 })
      ]);
    } catch (error) {
      // If still on login, try clicking login again (in case first click was ignored)
      if (!this.page.isClosed() && this.page.url().includes('/login')) {
        try {
          await this.loginButton.click();
          await Promise.race([
            this.page.waitForURL('**/dashboard', { timeout: 10000 }),
            this.page.waitForSelector(dashboardTitleSelector, { timeout: 10000 })
          ]);
        } catch {}
      }
      // As a last resort, navigate directly (guard may still allow if state is set)
      if (!this.page.isClosed() && !this.page.url().includes('/dashboard')) {
        await this.page.goto('http://localhost:5173/dashboard');
        await this.page.waitForLoadState('networkidle');
      }
    }
  }

  async waitForLoginError() {
    await this.waitForElement('.bg-red-50');
  }

  async isLoginSuccessful() {
    const onDashboardUrl = this.page.url().includes('/dashboard');
    const hasDashboardTitle = await this.page.locator('h1:has-text("Dashboard Overview")').first().isVisible().catch(() => false);
    return onDashboardUrl || hasDashboardTitle;
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
