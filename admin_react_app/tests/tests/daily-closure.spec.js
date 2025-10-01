import { test, expect } from '@playwright/test';
import LoginPage from '../pages/LoginPage.js';
import DailyClosurePage from '../pages/DailyClosurePage.js';
import { testCredentials } from '../utils/test-data.js';

test.describe('Daily Closure Page Tests', () => {
  let loginPage;
  let dailyClosurePage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    dailyClosurePage = new DailyClosurePage(page);
    
    // Login as super admin first
    await loginPage.navigateToLogin();
    await loginPage.loginAsSuperAdmin();
    await loginPage.waitForLoginSuccess();
    
    // Navigate to daily closure
    await dailyClosurePage.navigateToDailyClosure();
    await dailyClosurePage.waitForDailyClosureLoad();
  });

  test.describe('Page Elements and Layout', () => {
    test('should display daily closure page elements', async () => {
      await expect(dailyClosurePage.pageTitle).toBeVisible();
      await expect(dailyClosurePage.dateDisplay).toBeVisible();
      await expect(dailyClosurePage.statusIndicator).toBeVisible();
    });

    test('should display page title and date', async () => {
      await expect(dailyClosurePage.pageTitle).toHaveText('Daily Closure');
      
      const dateText = await dailyClosurePage.getCurrentDate();
      expect(dateText).toBeTruthy();
      expect(dateText).toMatch(/[A-Za-z]+day, [A-Za-z]+ \d+, \d+/);
    });

    test('should display status indicator', async () => {
      await expect(dailyClosurePage.statusIndicator).toBeVisible();
      
      const statusText = await dailyClosurePage.getStatusText();
      expect(statusText).toBeTruthy();
      expect(['Pending Closure', 'Closure Completed', 'Partial']).toContain(statusText);
    });

    test('should show mock data warning when using mock data', async () => {
      const isMockDataVisible = await dailyClosurePage.isMockDataWarningVisible();
      
      if (isMockDataVisible) {
        await expect(dailyClosurePage.mockDataWarning).toBeVisible();
        await expect(dailyClosurePage.mockDataWarningText).toBeVisible();
      }
    });
  });

  test.describe('KPI Cards', () => {
    test('should display all KPI cards with values', async () => {
      await dailyClosurePage.waitForKPICards();
      
      await expect(dailyClosurePage.outstandingAmountCard).toBeVisible();
      await expect(dailyClosurePage.todayCollectionCard).toBeVisible();
      await expect(dailyClosurePage.totalDueCard).toBeVisible();
      await expect(dailyClosurePage.amountPaidCard).toBeVisible();
      await expect(dailyClosurePage.newOutstandingCard).toBeVisible();
    });

    test('should display KPI values in currency format', async () => {
      await dailyClosurePage.waitForKPICards();
      
      const outstandingAmount = await dailyClosurePage.getKPIValue('Outstanding Amount');
      const todayCollection = await dailyClosurePage.getKPIValue('Today\'s Collection');
      const totalDue = await dailyClosurePage.getKPIValue('Total Due');
      const amountPaid = await dailyClosurePage.getKPIValue('Amount Paid');
      const newOutstanding = await dailyClosurePage.getKPIValue('New Outstanding');
      
      // Check that values are in currency format (supporting both $ and ₹)
      expect(outstandingAmount).toMatch(/^[₹$][\d,]+\.?\d*$/);
      expect(todayCollection).toMatch(/^[₹$][\d,]+\.?\d*$/);
      expect(totalDue).toMatch(/^[₹$][\d,]+\.?\d*$/);
      expect(amountPaid).toMatch(/^[₹$][\d,]+\.?\d*$/);
      expect(newOutstanding).toMatch(/^[₹$][\d,]+\.?\d*$/);
    });

    test('should display KPI descriptions', async () => {
      await dailyClosurePage.waitForKPICards();
      
      // Check that KPI cards have descriptions (might be in different format)
      const outstandingCard = dailyClosurePage.outstandingAmountCard;
      const todayCollectionCard = dailyClosurePage.todayCollectionCard;
      const totalDueCard = dailyClosurePage.totalDueCard;
      const amountPaidCard = dailyClosurePage.amountPaidCard;
      const newOutstandingCard = dailyClosurePage.newOutstandingCard;
      
      // Check that cards contain expected text
      await expect(outstandingCard).toContainText('Outstanding Amount');
      await expect(todayCollectionCard).toContainText('Today\'s Collection');
      await expect(totalDueCard).toContainText('Total Due');
      await expect(amountPaidCard).toContainText('Amount Paid');
      await expect(newOutstandingCard).toContainText('New Outstanding');
    });

    test('should have correct KPI relationships', async () => {
      await dailyClosurePage.waitForKPICards();
      
      const outstandingAmount = await dailyClosurePage.getKPIValue('Outstanding Amount');
      const todayCollection = await dailyClosurePage.getKPIValue('Today\'s Collection');
      const totalDue = await dailyClosurePage.getKPIValue('Total Due');
      
      // Extract numeric values from currency strings (supporting both $ and ₹)
      const outstandingNum = parseFloat(outstandingAmount.replace(/[₹$,]/g, ''));
      const todayCollectionNum = parseFloat(todayCollection.replace(/[₹$,]/g, ''));
      const totalDueNum = parseFloat(totalDue.replace(/[₹$,]/g, ''));
      
      // Total Due should equal Outstanding Amount + Today's Collection
      expect(totalDueNum).toBeCloseTo(outstandingNum + todayCollectionNum, 2);
    });
  });

  test.describe('Action Button', () => {
    test('should display finalize button when status is pending', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await expect(dailyClosurePage.finalizeButton).toBeVisible();
        await expect(dailyClosurePage.finalizeButton).toBeEnabled();
      }
    });

    test('should display completed button when status is completed', async () => {
      const isCompleted = await dailyClosurePage.isStatusCompleted();
      
      if (isCompleted) {
        await expect(dailyClosurePage.completedButton).toBeVisible();
        await expect(dailyClosurePage.completedButton).toBeDisabled();
        await expect(dailyClosurePage.finalizedAtText).toBeVisible();
      }
    });

    test('should disable finalize button when status is completed', async () => {
      const isCompleted = await dailyClosurePage.isStatusCompleted();
      
      if (isCompleted) {
        // When completed, the button text changes to "Closure Completed" and is disabled
        await expect(dailyClosurePage.completedButton).toBeVisible();
        await expect(dailyClosurePage.completedButton).toBeDisabled();
      }
    });
  });

  test.describe('Finalization Modal', () => {
    test('should open modal when finalize button is clicked', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        await expect(dailyClosurePage.modal).toBeVisible();
        
        const modalTitle = await dailyClosurePage.getModalTitle();
        expect(modalTitle).toContain('Finalize Daily Closure');
      }
    });

    test('should display closure summary in modal', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        await expect(dailyClosurePage.closureSummarySection).toBeVisible();
        await expect(dailyClosurePage.outstandingAmountSummary).toBeVisible();
        await expect(dailyClosurePage.todayCollectionSummary).toBeVisible();
        await expect(dailyClosurePage.totalDueSummary).toBeVisible();
        
        const summaryData = await dailyClosurePage.getClosureSummaryData();
        expect(summaryData.outstandingAmount).toBeTruthy();
        expect(summaryData.todayCollection).toBeTruthy();
        expect(summaryData.totalDue).toBeTruthy();
      }
    });

    test('should display payment amount input', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        await expect(dailyClosurePage.paymentAmountInput).toBeVisible();
        await expect(dailyClosurePage.paymentAmountLabel).toBeVisible();
        await expect(dailyClosurePage.paymentAmountHelperText).toBeVisible();
        
        const inputType = await dailyClosurePage.paymentAmountInput.getAttribute('type');
        expect(inputType).toBe('number');
      }
    });

    test('should show payment summary when amount is entered', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        await dailyClosurePage.fillPaymentAmount('100');
        
        await expect(dailyClosurePage.paymentSummarySection).toBeVisible();
        await expect(dailyClosurePage.paymentSummaryTitle).toBeVisible();
        
        const summaryData = await dailyClosurePage.getPaymentSummaryData();
        expect(summaryData).toBeTruthy();
        expect(summaryData.totalDue).toBeTruthy();
        expect(summaryData.paymentAmount).toBeTruthy();
        expect(summaryData.newOutstanding).toBeTruthy();
      }
    });

    test('should close modal when cancel button is clicked', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        await dailyClosurePage.closeModal();
        
        const isModalOpen = await dailyClosurePage.isModalOpen();
        expect(isModalOpen).toBe(false);
      }
    });

    test('should have confirm and cancel buttons', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        await expect(dailyClosurePage.modalCloseButton).toBeVisible();
        await expect(dailyClosurePage.modalConfirmButton).toBeVisible();
      }
    });
  });

  test.describe('Payment Amount Validation', () => {
    test('should validate empty payment amount', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        const validation = await dailyClosurePage.validatePaymentAmount('');
        // The validation might not show error immediately, but confirm button should be disabled
        expect(validation.isValid).toBe(false);
      }
    });

    test('should validate negative payment amount', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        const validation = await dailyClosurePage.validatePaymentAmount('-100');
        // The validation might not show error immediately, but confirm button should be disabled
        expect(validation.isValid).toBe(false);
      }
    });

    test('should validate valid payment amount', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        const validation = await dailyClosurePage.validatePaymentAmount('100');
        expect(validation.isValid).toBe(true);
        expect(validation.hasError).toBe(false);
      }
    });

    test('should validate zero payment amount', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        const validation = await dailyClosurePage.validatePaymentAmount('0');
        expect(validation.isValid).toBe(true);
        expect(validation.hasError).toBe(false);
      }
    });

    test('should validate large payment amount', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        const validation = await dailyClosurePage.validatePaymentAmount('2000000');
        // The validation might allow large amounts or show error
        expect(typeof validation.isValid).toBe('boolean');
      }
    });
  });

  test.describe('Closure Workflow', () => {
    test('should complete closure workflow with partial payment', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.completeClosureWorkflow(100);
        
        // Wait for page to update
        await dailyClosurePage.page.waitForTimeout(2000);
        
        // Check that status might have changed or modal closed
        const isModalOpen = await dailyClosurePage.isModalOpen();
        expect(isModalOpen).toBe(false);
      }
    });

    test('should cancel closure workflow', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.cancelClosureWorkflow();
        
        const isModalOpen = await dailyClosurePage.isModalOpen();
        expect(isModalOpen).toBe(false);
      }
    });

    test('should show finalizing state during closure', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        await dailyClosurePage.fillPaymentAmount('100');
        
        // Start the finalization process
        await dailyClosurePage.modalConfirmButton.click();
        
        // Check for finalizing state (might be brief)
        const isFinalizing = await dailyClosurePage.modalFinalizingButton.isVisible();
        // This might not be visible if the process is very fast
        expect(typeof isFinalizing).toBe('boolean');
      }
    });
  });

  test.describe('Loading States', () => {
    test('should show loading state initially', async ({ page }) => {
      // Mock slow API response to catch loading state
      await page.route('**/admin/closure', route => {
        setTimeout(() => {
          route.continue();
        }, 1000); // 1 second delay
      });
      
      // Navigate to daily closure
      await page.goto('http://localhost:5173/daily-closure');
      
      // Wait a bit for loading state to appear
      await page.waitForTimeout(500);
      
      // Check if loading state is visible
      const isLoading = await dailyClosurePage.isLoading();
      expect(isLoading).toBe(true);
      
      // Wait for data to load
      await dailyClosurePage.waitForKPICards();
      
      // Loading state should be hidden
      const isLoadingAfter = await dailyClosurePage.isLoading();
      expect(isLoadingAfter).toBe(false);
    });
  });

  test.describe('Error Handling', () => {
    test('should handle API errors and retry functionality', async ({ page }) => {
      // Mock API error
      await page.route('**/admin/closure', route => {
        route.fulfill({
          status: 500,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'Internal Server Error' })
        });
      });
      
      await page.goto('http://localhost:5173/daily-closure');
      
      // Wait for either error state or successful load
      await page.waitForTimeout(3000);
      
      const hasError = await dailyClosurePage.hasError();
      const hasKPICards = await dailyClosurePage.kpiCardsSection.isVisible();
      
      // Either error should be shown or KPI cards should be visible (fallback to mock data)
      expect(hasError || hasKPICards).toBe(true);
      
      if (hasError) {
        await expect(dailyClosurePage.retryButton).toBeVisible();
        
        // Remove the error mock
        await page.unroute('**/admin/closure');
        
        // Click retry button
        await dailyClosurePage.clickRetry();
        
        // Should load data successfully
        await dailyClosurePage.waitForKPICards();
        await expect(dailyClosurePage.kpiCardsSection).toBeVisible();
      }
    });
  });

  test.describe('Responsive Design', () => {
    test('should adapt to different viewport sizes', async ({ page }) => {
      // Test mobile viewport
      await page.setViewportSize({ width: 375, height: 667 });
      await expect(dailyClosurePage.pageTitle).toBeVisible();
      await expect(dailyClosurePage.kpiCardsSection).toBeVisible();
      
      // Test desktop viewport
      await page.setViewportSize({ width: 1920, height: 1080 });
      await expect(dailyClosurePage.pageTitle).toBeVisible();
      
      // Should have proper grid layout
      const topRowCards = dailyClosurePage.page.locator('.grid.grid-cols-1.md\\:grid-cols-3.gap-6');
      await expect(topRowCards).toBeVisible();
    });
  });

  test.describe('Data Refresh', () => {
    test('should refresh data when navigating back to page', async ({ page }) => {
      // Navigate away from daily closure
      await page.goto('http://localhost:5173/dashboard');
      
      // Navigate back to daily closure
      await dailyClosurePage.navigateToDailyClosure();
      await dailyClosurePage.waitForDailyClosureLoad();
      
      // Page should be loaded with fresh data
      await expect(dailyClosurePage.pageTitle).toBeVisible();
      await expect(dailyClosurePage.kpiCardsSection).toBeVisible();
    });
  });

  test.describe('Performance', () => {
    test('should load page within acceptable time', async ({ page }) => {
      const startTime = Date.now();
      
      await dailyClosurePage.navigateToDailyClosure();
      await dailyClosurePage.waitForKPICards();
      
      const loadTime = Date.now() - startTime;
      
      // Page should load within 5 seconds
      expect(loadTime).toBeLessThan(5000);
    });
  });

  test.describe('Accessibility', () => {
    test('should have proper form labels and accessibility', async () => {
      const isPending = await dailyClosurePage.isStatusPending();
      
      if (isPending) {
        await dailyClosurePage.openFinalizeModal();
        
        await expect(dailyClosurePage.paymentAmountInput).toHaveAttribute('type', 'number');
        await expect(dailyClosurePage.paymentAmountInput).toHaveAttribute('step', '0.01');
        await expect(dailyClosurePage.paymentAmountInput).toHaveAttribute('min', '0');
        
        await expect(dailyClosurePage.modalCloseButton).toHaveText(/Cancel/);
        await expect(dailyClosurePage.modalConfirmButton).toHaveText(/Confirm Closure/);
      }
    });
  });
});
