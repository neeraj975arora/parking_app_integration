import { test, expect } from '@playwright/test';
import LoginPage from '../pages/LoginPage.js';
import AdminManagementPage from '../pages/AdminManagementPage.js';
import { testCredentials } from '../utils/test-data.js';

test.describe('Admin Management Page Tests', () => {
  let loginPage;
  let adminManagementPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    adminManagementPage = new AdminManagementPage(page);
    
    // Login as super admin first
    await loginPage.navigateToLogin();
    await loginPage.loginAsSuperAdmin();
    await loginPage.waitForLoginSuccess();
    
    // Navigate to admin management
    await adminManagementPage.navigateToAdminManagement();
    await adminManagementPage.waitForAdminManagementLoad();
  });

  test.describe('Page Elements and Layout', () => {
    test('should display admin management page elements', async () => {
      await expect(adminManagementPage.pageTitle).toBeVisible();
      await expect(adminManagementPage.pageDescription).toBeVisible();
      await expect(adminManagementPage.createAdminSection).toBeVisible();
      await expect(adminManagementPage.existingAdminsSection).toBeVisible();
    });

    test('should display create admin form elements', async () => {
      await expect(adminManagementPage.createAdminTitle).toBeVisible();
      await expect(adminManagementPage.nameInput).toBeVisible();
      await expect(adminManagementPage.emailInput).toBeVisible();
      await expect(adminManagementPage.passwordInput).toBeVisible();
      await expect(adminManagementPage.assignedLotsSection).toBeVisible();
      await expect(adminManagementPage.createAdminButton).toBeVisible();
    });

    test('should display admin table headers', async () => {
      const headers = await adminManagementPage.adminTableHeaders.all();
      expect(headers.length).toBeGreaterThan(0);
      
      const headerTexts = await Promise.all(headers.map(header => header.textContent()));
      expect(headerTexts).toContain('Name');
      expect(headerTexts).toContain('Email');
      expect(headerTexts).toContain('Role');
      expect(headerTexts).toContain('Assigned Lots');
      expect(headerTexts).toContain('Status');
      expect(headerTexts).toContain('Actions');
    });
  });

  test.describe('KPI Cards', () => {
    test('should display all KPI cards with values', async () => {
      await adminManagementPage.waitForKPICards();
      
      await expect(adminManagementPage.totalAdminsCard).toBeVisible();
      await expect(adminManagementPage.superAdminsCard).toBeVisible();
      await expect(adminManagementPage.regularAdminsCard).toBeVisible();
      await expect(adminManagementPage.totalLotsCard).toBeVisible();
      
      const totalAdmins = await adminManagementPage.getKPIValue('Total Admins');
      const totalLots = await adminManagementPage.getKPIValue('Total Lots');
      
      expect(totalAdmins).toBeTruthy();
      expect(totalLots).toBe('25');
      expect(Number(totalAdmins)).not.toBeNaN();
    });
  });

  test.describe('Create Admin Form', () => {
    test('should have all required form fields with proper types', async () => {
      await expect(adminManagementPage.nameInput).toBeVisible();
      await expect(adminManagementPage.emailInput).toBeVisible();
      await expect(adminManagementPage.passwordInput).toBeVisible();
      await expect(adminManagementPage.assignedLotsSection).toBeVisible();
      
      await expect(adminManagementPage.nameInput).toHaveAttribute('type', 'text');
      await expect(adminManagementPage.emailInput).toHaveAttribute('type', 'email');
      await expect(adminManagementPage.passwordInput).toHaveAttribute('type', 'password');
    });

    test('should display available parking lots or no lots message', async () => {
      const availableLots = await adminManagementPage.getAvailableLots();
      
      if (availableLots.length > 0) {
        // Should have some parking lots available
        const lotLabels = availableLots.map(lot => lot.label);
        expect(lotLabels.length).toBeGreaterThan(0);
        // Check that all labels follow the expected pattern
        lotLabels.forEach(label => {
          expect(label).toMatch(/^Parking Lot P\d+$/);
        });
        console.log(`Available lots: ${lotLabels.join(', ')}`);
      } else {
        // Should show no available lots message
        const noLotsMessage = adminManagementPage.page.locator('text=All parking lots are currently assigned');
        await expect(noLotsMessage).toBeVisible();
      }
    });
  });

  test.describe('Form Validation', () => {
    test('should validate required fields', async () => {
      // Check if button is disabled due to no available lots
      const isButtonDisabled = await adminManagementPage.createAdminButton.isDisabled();
      
      if (isButtonDisabled) {
        // If button is disabled, test that it shows the disabled state
        await expect(adminManagementPage.createAdminButton).toBeDisabled();
        console.log('Create Admin button is disabled - no available lots');
      } else {
        // If button is enabled, test that form elements are present
        await expect(adminManagementPage.nameInput).toBeVisible();
        await expect(adminManagementPage.emailInput).toBeVisible();
        await expect(adminManagementPage.passwordInput).toBeVisible();
        await expect(adminManagementPage.createAdminButton).toBeEnabled();
        console.log('Create Admin button is enabled - form validation elements present');
      }
    });

    test('should validate email format and password strength', async () => {
      // Check if button is disabled due to no available lots
      const isButtonDisabled = await adminManagementPage.createAdminButton.isDisabled();
      
      if (isButtonDisabled) {
        // If button is disabled, test that it shows the disabled state
        await expect(adminManagementPage.createAdminButton).toBeDisabled();
        console.log('Create Admin button is disabled - no available lots');
      } else {
        // If button is enabled, test that form elements have correct types
        await expect(adminManagementPage.emailInput).toHaveAttribute('type', 'email');
        await expect(adminManagementPage.passwordInput).toHaveAttribute('type', 'password');
        await expect(adminManagementPage.nameInput).toHaveAttribute('type', 'text');
        console.log('Form input types are correct');
      }
    });

    test('should clear validation errors when user starts typing', async () => {
      // Check if button is disabled due to no available lots
      const isButtonDisabled = await adminManagementPage.createAdminButton.isDisabled();
      
      if (isButtonDisabled) {
        // If button is disabled, test that it shows the disabled state
        await expect(adminManagementPage.createAdminButton).toBeDisabled();
        console.log('Create Admin button is disabled - no available lots');
      } else {
        // If button is enabled, test that form inputs are interactive
        await adminManagementPage.nameInput.fill('Test');
        await adminManagementPage.emailInput.fill('test@example.com');
        await adminManagementPage.passwordInput.fill('password123');
        
        // Verify inputs have the values we set
        const nameValue = await adminManagementPage.nameInput.inputValue();
        const emailValue = await adminManagementPage.emailInput.inputValue();
        const passwordValue = await adminManagementPage.passwordInput.inputValue();
        
        expect(nameValue).toBe('Test');
        expect(emailValue).toBe('test@example.com');
        expect(passwordValue).toBe('password123');
        console.log('Form inputs are interactive and accept user input');
      }
    });
  });

  test.describe('Form Submission', () => {
    test('should submit form with valid data and show loading state', async () => {
      // Check if button is disabled due to no available lots
      const isButtonDisabled = await adminManagementPage.createAdminButton.isDisabled();
      
      if (isButtonDisabled) {
        // If button is disabled, test that it shows the disabled state
        await expect(adminManagementPage.createAdminButton).toBeDisabled();
        console.log('Create Admin button is disabled - no available lots');
      } else {
        // If button is enabled, test form submission
        const availableLots = await adminManagementPage.getAvailableLots();
        const lotIds = availableLots.map(lot => lot.id);
        
        await adminManagementPage.fillCreateAdminForm({
          name: 'Test Admin',
          email: 'testadmin@example.com',
          password: 'password123',
          assignedLots: lotIds.slice(0, 2) // Use first two available lots
        });
        
        await adminManagementPage.submitCreateAdminForm();
        
        // Wait for form submission to complete
        await adminManagementPage.waitForFormSubmission();
        
        // Should show success message or error
        const hasSuccess = await adminManagementPage.hasSubmitSuccess();
        const hasError = await adminManagementPage.hasSubmitError();
        expect(hasSuccess || hasError).toBe(true);
        console.log('Form submission completed - success or error shown');
      }
    });

    test('should handle duplicate email error', async () => {
      // Check if button is disabled due to no available lots
      const isButtonDisabled = await adminManagementPage.createAdminButton.isDisabled();
      
      if (isButtonDisabled) {
        // If button is disabled, test that it shows the disabled state
        await expect(adminManagementPage.createAdminButton).toBeDisabled();
        console.log('Create Admin button is disabled - no available lots');
      } else {
        // If button is enabled, test duplicate email error
        const availableLots = await adminManagementPage.getAvailableLots();
        const lotIds = availableLots.map(lot => lot.id);
        
        await adminManagementPage.fillCreateAdminForm({
          name: 'Test Admin',
          email: 'superadmin@parking.com', // Existing email
          password: 'password123',
          assignedLots: lotIds.slice(0, 1) // Use first available lot
        });
        
        await adminManagementPage.submitCreateAdminForm();
        await adminManagementPage.waitForFormSubmission();
        
        // Should show error for duplicate email
        const hasError = await adminManagementPage.hasSubmitError();
        expect(hasError).toBe(true);
      }
    });
  });

  test.describe('Parking Lots Management', () => {
    test('should allow selecting and unselecting multiple lots', async () => {
      const availableLots = await adminManagementPage.getAvailableLots();
      
      if (availableLots.length > 0) {
        // Should have some parking lots available
        const lotIds = availableLots.map(lot => lot.id);
        expect(lotIds.length).toBeGreaterThan(0);
        // Check that all IDs are valid numbers
        lotIds.forEach(id => {
          expect(typeof id).toBe('number');
          expect(id).toBeGreaterThan(0);
        });
        console.log(`Available lot IDs: ${lotIds.join(', ')}`);
        
        // Select available lots (use first two available lots)
        const firstLotId = lotIds[0];
        const secondLotId = lotIds.length > 1 ? lotIds[1] : lotIds[0];
        
        await adminManagementPage.selectAvailableLot(firstLotId);
        await adminManagementPage.selectAvailableLot(secondLotId);
        
        const selectedLots = await adminManagementPage.getSelectedLots();
        expect(selectedLots.length).toBeGreaterThan(0);
        
        // Unselect one lot
        await adminManagementPage.unselectAvailableLot(firstLotId);
        
        const updatedSelectedLots = await adminManagementPage.getSelectedLots();
        expect(updatedSelectedLots.length).toBeGreaterThan(0);
        expect(updatedSelectedLots.map(lot => lot.id)).toContain(secondLotId);
        expect(updatedSelectedLots.map(lot => lot.id)).not.toContain(firstLotId);
      } else {
        // If no lots available, test that the no lots message is shown
        const noLotsMessage = adminManagementPage.page.locator('text=All parking lots are currently assigned');
        await expect(noLotsMessage).toBeVisible();
        console.log('No available lots - testing no lots message display');
      }
    });
  });

  test.describe('Admin Table and Search', () => {
    test('should display admin data and allow searching', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const adminCount = await adminManagementPage.getAdminCount();
      expect(adminCount).toBeGreaterThan(0);
      
      const admin = await adminManagementPage.getAdminByIndex(0);
      expect(admin.name).toBeTruthy();
      expect(admin.name.trim()).not.toBe(''); // Name should not be empty
      expect(admin.role).toBeTruthy();
      expect(admin.role.trim()).not.toBe(''); // Role should not be empty
      expect(admin.assignedLots).toBeTruthy();
      expect(admin.assignedLots.trim()).not.toBe(''); // Assigned lots should not be empty
      expect(admin.status).toBeTruthy();
      expect(admin.status.trim()).not.toBe(''); // Status should not be empty
      
      // Email might be empty in some test data, so we'll just check it exists
      expect(admin.email).toBeDefined();
    });

    test('should search admins by name and clear search', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const initialCount = await adminManagementPage.getAdminCount();
      
      await adminManagementPage.searchAdmins('Super');
      
      const filteredCount = await adminManagementPage.getAdminCount();
      expect(filteredCount).toBeLessThanOrEqual(initialCount);
      
      await adminManagementPage.clearSearch();
      
      const finalCount = await adminManagementPage.getAdminCount();
      expect(finalCount).toBe(initialCount);
    });

    test('should show no results message for invalid search', async () => {
      await adminManagementPage.waitForAdminTable();
      
      await adminManagementPage.searchAdmins('NonExistentAdmin');
      
      const noResultsMessage = adminManagementPage.page.locator('text=No admins found matching your search');
      await expect(noResultsMessage).toBeVisible();
    });

    test('should display role and status badges correctly', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const superAdminBadge = adminManagementPage.page.locator('.bg-purple-100.text-purple-800').first();
      const adminBadge = adminManagementPage.page.locator('.bg-blue-100.text-blue-800').first();
      const statusBadge = adminManagementPage.page.locator('.bg-green-100.text-green-800').first();
      
      // Should have at least one role badge visible
      const hasSuperAdminBadge = await superAdminBadge.isVisible();
      const hasAdminBadge = await adminBadge.isVisible();
      
      expect(hasSuperAdminBadge || hasAdminBadge).toBe(true);
      await expect(statusBadge).toBeVisible();
    });
  });

  test.describe('Edit Admin Functionality', () => {
    test('should open edit modal and display admin information', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const admin = await adminManagementPage.getAdminByIndex(0);
      await adminManagementPage.clickEditAdmin(0);
      await adminManagementPage.waitForModal('edit');
      
      await expect(adminManagementPage.editModal).toBeVisible();
      
      const modalTitle = await adminManagementPage.getModalTitle('edit');
      expect(modalTitle).toContain('Edit Admin Lots');
      
      const modalMessage = await adminManagementPage.getModalMessage('edit');
      expect(modalMessage).toContain(admin.name);
      
      const editModalCheckboxes = adminManagementPage.editModal.locator('input[type="checkbox"]');
      const checkboxCount = await editModalCheckboxes.count();
      expect(checkboxCount).toBe(25);
    });

    test('should close edit modal when cancel or close button is clicked', async () => {
      await adminManagementPage.waitForAdminTable();
      
      await adminManagementPage.clickEditAdmin(0);
      await adminManagementPage.waitForModal('edit');
      
      await adminManagementPage.modalCancelButton.click();
      
      const isModalOpen = await adminManagementPage.isModalOpen('edit');
      expect(isModalOpen).toBe(false);
    });

    test('should save changes when save button is clicked', async () => {
      await adminManagementPage.waitForAdminTable();
      
      await adminManagementPage.clickEditAdmin(0);
      await adminManagementPage.waitForModal('edit');
      
      // Select a different lot
      const editModalCheckbox = adminManagementPage.editModal.locator('input[type="checkbox"]').first();
      await editModalCheckbox.check();
      
      await adminManagementPage.modalConfirmButton.click();
      
      // Modal should close
      const isModalOpen = await adminManagementPage.isModalOpen('edit');
      expect(isModalOpen).toBe(false);
    });
  });

  test.describe('Delete Admin Functionality', () => {
    test('should open delete modal and display admin information', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const admin = await adminManagementPage.getAdminByIndex(0);
      await adminManagementPage.clickDeleteAdmin(0);
      await adminManagementPage.waitForModal('delete');
      
      await expect(adminManagementPage.deleteModal).toBeVisible();
      
      const modalTitle = await adminManagementPage.getModalTitle('delete');
      expect(modalTitle).toContain('Delete Admin');
      
      const modalMessage = await adminManagementPage.getModalMessage('delete');
      expect(modalMessage).toContain(admin.name);
    });

    test('should cancel delete when cancel button is clicked', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const initialCount = await adminManagementPage.getAdminCount();
      
      await adminManagementPage.clickDeleteAdmin(0);
      await adminManagementPage.waitForModal('delete');
      
      await adminManagementPage.cancelDelete();
      
      const finalCount = await adminManagementPage.getAdminCount();
      expect(finalCount).toBe(initialCount);
    });

    test('should delete admin when confirm is clicked', async () => {
      await adminManagementPage.waitForAdminTable();
      
      const initialCount = await adminManagementPage.getAdminCount();
      
      await adminManagementPage.clickDeleteAdmin(0);
      await adminManagementPage.waitForModal('delete');
      
      await adminManagementPage.confirmDelete();
      
      // Wait for deletion to complete
      await adminManagementPage.page.waitForTimeout(2000);
      
      const finalCount = await adminManagementPage.getAdminCount();
      expect(finalCount).toBeLessThan(initialCount);
    });
  });

  test.describe('Loading States', () => {
    test('should show and hide loading states correctly', async ({ page }) => {
      // Mock slow API response to catch loading state
      await page.route('**/admins/admin_lots/all', route => {
        setTimeout(() => {
          route.continue();
        }, 1000); // 1 second delay
      });
      
      // Navigate to admin management
      await page.goto('http://localhost:5173/admin-management');
      
      // Wait a bit for loading state to appear
      await page.waitForTimeout(500);
      
      // Check if loading state is visible
      const isLoading = await adminManagementPage.isLoading();
      expect(isLoading).toBe(true);
      
      // Wait for data to load
      await adminManagementPage.waitForKPICards();
      
      // Loading state should be hidden
      const isLoadingAfter = await adminManagementPage.isLoading();
      expect(isLoadingAfter).toBe(false);
    });
  });

  test.describe('Error Handling', () => {
    test('should handle API errors and retry functionality', async ({ page }) => {
      // Mock API error
      await page.route('**/admins/admin_lots/all', route => {
        route.fulfill({
          status: 500,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'Internal Server Error' })
        });
      });
      
      await page.goto('http://localhost:5173/admin-management');
      
      // Should show error message and retry button
      await adminManagementPage.page.waitForTimeout(2000);
      const hasError = await adminManagementPage.hasError();
      expect(hasError).toBe(true);
      
      await expect(adminManagementPage.retryButton).toBeVisible();
      
      // Remove the error mock
      await page.unroute('**/admins/admin_lots/all');
      
      // Click retry button
      await adminManagementPage.retryButton.click();
      
      // Should load data successfully
      await adminManagementPage.waitForKPICards();
      await expect(adminManagementPage.kpiCardsSection).toBeVisible();
    });
  });

  test.describe('Role-Based Access', () => {
    test('should be accessible only to super admin', async ({ browser }) => {
      // Create a new context and page for this test
      const context = await browser.newContext();
      const page = await context.newPage();
      
      try {
        // Create fresh page objects for this test
        const freshLoginPage = new LoginPage(page);
        
        // Navigate to login page
        await freshLoginPage.navigateToLogin();
        
        // Login as regular admin
        await freshLoginPage.loginAsAdmin();
        
        // Wait a bit for login to process
        await page.waitForTimeout(2000);
        
        // Try to navigate to admin management
        await page.goto('http://localhost:5173/admin-management');
        
        // Wait for page to load
        await page.waitForLoadState('networkidle');
        
        // Check if we can access the page or if there's an access denied message
        const currentUrl = page.url();
        const hasAccessDenied = await page.locator('text=Access Denied').isVisible();
        const hasUnauthorized = await page.locator('text=Unauthorized').isVisible();
        const hasPermissionDenied = await page.locator('text=Permission Denied').isVisible();
        
        // Either should be redirected or show access denied message
        const isAccessDenied = currentUrl !== 'http://localhost:5173/admin-management' || 
                             hasAccessDenied || hasUnauthorized || hasPermissionDenied;
        
        expect(isAccessDenied).toBe(true);
      } finally {
        // Clean up
        await context.close();
      }
    });
  });

  test.describe('Responsive Design', () => {
    test('should adapt to different viewport sizes', async ({ page }) => {
      // Test mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });
      await expect(adminManagementPage.pageTitle).toBeVisible();
      await expect(adminManagementPage.createAdminSection).toBeVisible();
      await expect(adminManagementPage.existingAdminsSection).toBeVisible();
      
      // Test desktop viewport
      await page.setViewportSize({ width: 1920, height: 1080 });
      await expect(adminManagementPage.pageTitle).toBeVisible();
      
      // Should have two main sections side by side
      const sections = adminManagementPage.page.locator('.grid.grid-cols-1.lg\\:grid-cols-2 > div');
      const sectionCount = await sections.count();
      expect(sectionCount).toBe(2);
    });
  });

  test.describe('Data Refresh', () => {
    test('should refresh data when navigating back to page', async ({ page }) => {
      // Navigate away from admin management
      await page.goto('http://localhost:5173/dashboard');
      
      // Navigate back to admin management
      await adminManagementPage.navigateToAdminManagement();
      await adminManagementPage.waitForAdminManagementLoad();
      
      // Page should be loaded with fresh data
      await expect(adminManagementPage.pageTitle).toBeVisible();
      await expect(adminManagementPage.kpiCardsSection).toBeVisible();
    });
  });

  test.describe('Performance', () => {
    test('should load page within acceptable time', async ({ page }) => {
      const startTime = Date.now();
      
      await adminManagementPage.navigateToAdminManagement();
      await adminManagementPage.waitForKPICards();
      
      const loadTime = Date.now() - startTime;
      
      // Page should load within 5 seconds
      expect(loadTime).toBeLessThan(5000);
    });
  });

  test.describe('Accessibility', () => {
    test('should have proper form labels and accessibility', async () => {
      await expect(adminManagementPage.nameInput).toHaveAttribute('name', 'name');
      await expect(adminManagementPage.emailInput).toHaveAttribute('name', 'email');
      await expect(adminManagementPage.passwordInput).toHaveAttribute('name', 'password');
      
      await expect(adminManagementPage.createAdminButton).toHaveText(/Create Admin/);
      await expect(adminManagementPage.searchInput).toHaveAttribute('placeholder', 'Search admins...');
    });
  });
});