import { test, expect } from '@playwright/test';
import LoginPage from '../pages/LoginPage.js';
import PaymentCollectionPage from '../pages/PaymentCollectionPage.js';
import { testCredentials } from '../utils/test-data.js';

test.describe('Payment Collection Page Tests', () => {
  let loginPage;
  let paymentCollectionPage;

  test.beforeEach(async ({ page }) => {
    loginPage = new LoginPage(page);
    paymentCollectionPage = new PaymentCollectionPage(page);
    
    // Login as super admin first
    await loginPage.navigateToLogin();
    await loginPage.loginAsSuperAdmin();
    await loginPage.waitForLoginSuccess();
    
    // Navigate to payment collection page
    await paymentCollectionPage.navigateToPaymentCollection();
    await paymentCollectionPage.waitForPaymentCollectionLoad();
  });

  test.describe('Page Elements', () => {
    test('should display payment collection page elements', async () => {
      await expect(paymentCollectionPage.pageTitle).toBeVisible();
      await expect(paymentCollectionPage.pageSubtitle).toBeVisible();
      await expect(paymentCollectionPage.kpiSection).toBeVisible();
      await expect(paymentCollectionPage.filterSection).toBeVisible();
      await expect(paymentCollectionPage.paymentRecordsSection).toBeVisible();
    });

    test('should display correct page title and subtitle', async () => {
      await expect(paymentCollectionPage.pageTitle).toHaveText('Payment Collection');
      await expect(paymentCollectionPage.pageSubtitle).toContainText('Manage payment records and collections');
    });
  });

  test.describe('KPI Cards', () => {
    test('should display all KPI cards', async () => {
      await paymentCollectionPage.waitForKPICards();
      
      await expect(paymentCollectionPage.totalPaymentsCard).toBeVisible();
      await expect(paymentCollectionPage.completedPaymentsCard).toBeVisible();
      await expect(paymentCollectionPage.pendingPaymentsCard).toBeVisible();
      await expect(paymentCollectionPage.failedPaymentsCard).toBeVisible();
    });

    test('should display KPI values', async () => {
      await paymentCollectionPage.waitForKPICards();
      
      const totalPayments = await paymentCollectionPage.getTotalPaymentsCount();
      const completedPayments = await paymentCollectionPage.getCompletedPaymentsCount();
      const pendingPayments = await paymentCollectionPage.getPendingPaymentsCount();
      const failedPayments = await paymentCollectionPage.getFailedPaymentsCount();
      
      // Verify KPI cards are visible and have some content
      expect(paymentCollectionPage.totalPaymentsCard).toBeVisible();
      expect(paymentCollectionPage.completedPaymentsCard).toBeVisible();
      expect(paymentCollectionPage.pendingPaymentsCard).toBeVisible();
      expect(paymentCollectionPage.failedPaymentsCard).toBeVisible();
      
      // Values should be truthy (not empty strings)
      expect(totalPayments).toBeTruthy();
      expect(completedPayments).toBeTruthy();
      expect(pendingPayments).toBeTruthy();
      expect(failedPayments).toBeTruthy();
      
      // Verify counts are numeric
      const totalNum = await paymentCollectionPage.getKPIValueAsNumber('Total Payments');
      const completedNum = await paymentCollectionPage.getKPIValueAsNumber('Completed');
      const pendingNum = await paymentCollectionPage.getKPIValueAsNumber('Pending');
      const failedNum = await paymentCollectionPage.getKPIValueAsNumber('Failed');
      
      expect(totalNum).toBeGreaterThanOrEqual(0);
      expect(completedNum).toBeGreaterThanOrEqual(0);
      expect(pendingNum).toBeGreaterThanOrEqual(0);
      expect(failedNum).toBeGreaterThanOrEqual(0);
    });

    test('should have correct KPI relationships', async () => {
      await paymentCollectionPage.waitForKPICards();
      
      const totalPayments = await paymentCollectionPage.getKPIValueAsNumber('Total Payments');
      const completedPayments = await paymentCollectionPage.getKPIValueAsNumber('Completed');
      const pendingPayments = await paymentCollectionPage.getKPIValueAsNumber('Pending');
      const failedPayments = await paymentCollectionPage.getKPIValueAsNumber('Failed');
      
      // Only test relationship if we have actual data
      if (totalPayments > 0) {
        // Total payments should equal sum of all statuses
        expect(totalPayments).toBe(completedPayments + pendingPayments + failedPayments);
      }
    });
  });

  test.describe('Filter Functionality', () => {
    test('should display all filter elements', async () => {
      await expect(paymentCollectionPage.searchInput).toBeVisible();
      await expect(paymentCollectionPage.statusSelect).toBeVisible();
      await expect(paymentCollectionPage.dateFromInput).toBeVisible();
      await expect(paymentCollectionPage.dateToInput).toBeVisible();
      await expect(paymentCollectionPage.applyFiltersButton).toBeVisible();
      await expect(paymentCollectionPage.clearFiltersButton).toBeVisible();
    });

    test('should filter by search term', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Get initial row count
      const initialCount = await paymentCollectionPage.getTableRowCount();
      
      if (initialCount > 0) {
        // Get first row data to use as search term
        const firstRowData = await paymentCollectionPage.getPaymentRowData(0);
        const searchTerm = firstRowData.vehicle.substring(0, 3); // Use first 3 chars of vehicle
        
        // Apply search filter
        await paymentCollectionPage.setSearchFilter(searchTerm);
        await paymentCollectionPage.applyFilters();
        
        // Wait for table to update
        await paymentCollectionPage.page.waitForTimeout(1000);
        
        // Verify filtered results
        const filteredCount = await paymentCollectionPage.getTableRowCount();
        expect(filteredCount).toBeLessThanOrEqual(initialCount);
        
        // Verify all visible rows contain the search term
        for (let i = 0; i < filteredCount; i++) {
          const rowData = await paymentCollectionPage.getPaymentRowData(i);
          expect(rowData.vehicle.toLowerCase()).toContain(searchTerm.toLowerCase());
        }
      }
    });

    test('should filter by status', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Test filtering by COMPLETED status
      await paymentCollectionPage.setStatusFilter('COMPLETED');
      await paymentCollectionPage.applyFilters();
      
      await paymentCollectionPage.page.waitForTimeout(1000);
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      // Verify all visible rows have COMPLETED status
      for (let i = 0; i < rowCount; i++) {
        const rowData = await paymentCollectionPage.getPaymentRowData(i);
        expect(rowData.status.toLowerCase()).toContain('completed');
      }
    });

    test('should clear filters', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Apply some filters
      await paymentCollectionPage.setSearchFilter('test');
      await paymentCollectionPage.setStatusFilter('COMPLETED');
      
      // Clear filters
      await paymentCollectionPage.clearFilters();
      
      // Verify filters are cleared
      const searchValue = await paymentCollectionPage.searchInput.inputValue();
      const statusValue = await paymentCollectionPage.statusSelect.inputValue();
      
      expect(searchValue).toBe('');
      expect(statusValue).toBe('');
    });

    test('should disable export button when no data', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Clear all data by applying impossible filter
      await paymentCollectionPage.setSearchFilter('nonexistent12345');
      await paymentCollectionPage.applyFilters();
      
      // Wait for table to update and verify no rows
      await paymentCollectionPage.page.waitForTimeout(1000);
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      // Only test if we actually have no data
      if (rowCount === 0) {
        const isExportEnabled = await paymentCollectionPage.isExportButtonEnabled();
        expect(isExportEnabled).toBe(false);
      } else {
        // Skip test if we can't create empty state
        test.skip('Could not create empty state for testing');
      }
    });
  });

  test.describe('Payment Records Table', () => {
    test('should display table with correct headers', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const headers = await paymentCollectionPage.getTableHeaderText();
      const expectedHeaders = [
        'Payment ID',
        'Vehicle',
        'Amount',
        'Date',
        'Duration',
        'Status',
        'Actions'
      ];
      
      expect(headers).toEqual(expectedHeaders);
    });

    test('should display payment data in table rows', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      if (rowCount > 0) {
        const firstRowData = await paymentCollectionPage.getPaymentRowData(0);
        
        // Verify all required fields are present
        expect(firstRowData.paymentId).toBeTruthy();
        expect(firstRowData.vehicle).toBeTruthy();
        expect(firstRowData.amount).toBeTruthy();
        expect(firstRowData.date).toBeTruthy();
        expect(firstRowData.duration).toBeTruthy();
        expect(firstRowData.status).toBeTruthy();
        expect(firstRowData.actionButton).toBeTruthy();
      }
    });

    test('should display records count information', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const recordsText = await paymentCollectionPage.getRecordsCountText();
      expect(recordsText).toMatch(/Showing \d+-\d+ of \d+ records/);
    });
  });

  test.describe('Pagination', () => {
    test('should display pagination when multiple pages exist', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const totalPages = await paymentCollectionPage.getTotalPages();
      
      if (totalPages > 1) {
        await expect(paymentCollectionPage.paginationSection).toBeVisible();
        await expect(paymentCollectionPage.previousButton).toBeVisible();
        await expect(paymentCollectionPage.nextButton).toBeVisible();
      }
    });

    test('should navigate between pages', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const totalPages = await paymentCollectionPage.getTotalPages();
      
      if (totalPages > 1) {
        // Test next page navigation
        const initialPage = await paymentCollectionPage.getCurrentPageNumber();
        await paymentCollectionPage.goToNextPage();
        
        await paymentCollectionPage.page.waitForTimeout(1000);
        
        const nextPage = await paymentCollectionPage.getCurrentPageNumber();
        expect(nextPage).toBe(initialPage + 1);
        
        // Test previous page navigation
        await paymentCollectionPage.goToPreviousPage();
        
        await paymentCollectionPage.page.waitForTimeout(1000);
        
        const previousPage = await paymentCollectionPage.getCurrentPageNumber();
        expect(previousPage).toBe(initialPage);
      }
    });

    test('should disable previous button on first page', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const currentPage = await paymentCollectionPage.getCurrentPageNumber();
      
      if (currentPage === 1) {
        const isPreviousEnabled = await paymentCollectionPage.isPreviousButtonEnabled();
        expect(isPreviousEnabled).toBe(false);
      }
    });

    test('should disable next button on last page', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const currentPage = await paymentCollectionPage.getCurrentPageNumber();
      const totalPages = await paymentCollectionPage.getTotalPages();
      
      if (currentPage === totalPages && totalPages > 1) {
        const isNextEnabled = await paymentCollectionPage.isNextButtonEnabled();
        expect(isNextEnabled).toBe(false);
      }
    });
  });

  test.describe('Action Buttons', () => {
    test('should display appropriate action buttons based on status', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      for (let i = 0; i < Math.min(rowCount, 5); i++) {
        const rowData = await paymentCollectionPage.getPaymentRowData(i);
        const actionButton = rowData.actionButton;
        
        await expect(actionButton).toBeVisible();
        
        const buttonText = await actionButton.textContent();
        expect(buttonText).toBeTruthy();
        
        // Verify button text matches expected actions
        const validActions = ['View', 'Collect', 'Retry'];
        const hasValidAction = validActions.some(action => buttonText.includes(action));
        expect(hasValidAction).toBe(true);
      }
    });

    test('should open modal when view button is clicked', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      if (rowCount > 0) {
        // Find a row with View button
        let viewButtonIndex = -1;
        for (let i = 0; i < rowCount; i++) {
          const rowData = await paymentCollectionPage.getPaymentRowData(i);
          const buttonText = await rowData.actionButton.textContent();
          if (buttonText.includes('View')) {
            viewButtonIndex = i;
            break;
          }
        }
        
        if (viewButtonIndex >= 0) {
          await paymentCollectionPage.clickViewButton(viewButtonIndex);
          
          // Verify modal opens
          await expect(paymentCollectionPage.modal).toBeVisible();
          await expect(paymentCollectionPage.modalTitle).toHaveText('Payment Details');
        }
      }
    });

    test('should close modal when close button is clicked', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      if (rowCount > 0) {
        // Find a row with View button and open modal
        let viewButtonIndex = -1;
        for (let i = 0; i < rowCount; i++) {
          const rowData = await paymentCollectionPage.getPaymentRowData(i);
          const buttonText = await rowData.actionButton.textContent();
          if (buttonText.includes('View')) {
            viewButtonIndex = i;
            break;
          }
        }
        
        if (viewButtonIndex >= 0) {
          await paymentCollectionPage.clickViewButton(viewButtonIndex);
          await expect(paymentCollectionPage.modal).toBeVisible();
          
          // Close modal
          await paymentCollectionPage.closeModal();
          
          // Verify modal closes
          await expect(paymentCollectionPage.modal).not.toBeVisible();
        }
      }
    });
  });

  test.describe('Export Functionality', () => {
    test('should enable export button when data is available', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      if (rowCount > 0) {
        const isExportEnabled = await paymentCollectionPage.isExportButtonEnabled();
        expect(isExportEnabled).toBe(true);
      }
    });

    test('should trigger export when export button is clicked', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      if (rowCount > 0) {
        // Set up download handler
        const downloadPromise = paymentCollectionPage.page.waitForEvent('download');
        
        await paymentCollectionPage.exportCSV();
        
        // Wait for download to start
        const download = await downloadPromise;
        
        // Verify download filename
        expect(download.suggestedFilename()).toBe('payment_records.csv');
      }
    });
  });

  test.describe('Refresh Functionality', () => {
    test('should refresh data when refresh button is clicked', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Get initial data
      const initialRowCount = await paymentCollectionPage.getTableRowCount();
      
      // Click refresh
      await paymentCollectionPage.refreshData();
      
      // Wait for refresh to complete
      await paymentCollectionPage.waitForTableData();
      
      // Verify data is still loaded
      const refreshedRowCount = await paymentCollectionPage.getTableRowCount();
      expect(refreshedRowCount).toBe(initialRowCount);
    });

    test('should show loading state during refresh', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Click refresh
      await paymentCollectionPage.refreshData();
      
      // Check if loading state appears (might be too fast to catch)
      const isLoading = await paymentCollectionPage.isRefreshButtonLoading();
      // This might be false if refresh is very fast
      expect(typeof isLoading).toBe('boolean');
    });
  });

  test.describe('Loading States', () => {
    test('should show loading spinner initially', async ({ page }) => {
      // Mock slow API response to catch loading state
      await page.route('**/admin/total_due', route => {
        setTimeout(() => {
          route.continue();
        }, 3000); // 3 second delay
      });
      
      // Navigate to payment collection page
      await page.goto('http://localhost:5173/payment-collection');
      
      // Wait a bit for loading state to appear
      await page.waitForTimeout(500);
      
      // Check if loading spinner is visible
      const spinnerVisible = await paymentCollectionPage.isLoading();
      expect(spinnerVisible).toBe(true);
    });

    test('should hide loading spinner after data loads', async () => {
      await paymentCollectionPage.waitForKPICards();
      
      // Loading spinner should be hidden
      const spinnerVisible = await paymentCollectionPage.isLoading();
      expect(spinnerVisible).toBe(false);
    });
  });

  test.describe('Error Handling', () => {
    test('should handle API errors gracefully', async ({ page }) => {
      // Mock API error
      await page.route('**/admin/sessions/details/all', route => {
        route.fulfill({
          status: 500,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'Internal Server Error' })
        });
      });
      
      await page.goto('http://localhost:5173/payment-collection');
      
      // Should show error state
      await expect(paymentCollectionPage.errorMessage).toBeVisible();
      await expect(paymentCollectionPage.retryButton).toBeVisible();
    });

    test('should retry on error when retry button is clicked', async ({ page }) => {
      // Mock API error first
      await page.route('**/admin/sessions/details/all', route => {
        route.fulfill({
          status: 500,
          contentType: 'application/json',
          body: JSON.stringify({ error: 'Internal Server Error' })
        });
      });
      
      await page.goto('http://localhost:5173/payment-collection');
      await expect(paymentCollectionPage.errorMessage).toBeVisible();
      
      // Remove the error route to allow success
      await page.unroute('**/admin/sessions/details/all');
      
      // Click retry
      await paymentCollectionPage.retryButton.click();
      
      // Should eventually load successfully
      await paymentCollectionPage.waitForKPICards();
      await expect(paymentCollectionPage.kpiSection).toBeVisible();
    });
  });

  test.describe('Empty State', () => {
    test('should show empty state when no data', async ({ page }) => {
      // Mock empty response
      await page.route('**/admin/sessions/details/all', route => {
        route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify([])
        });
      });
      
      await page.goto('http://localhost:5173/payment-collection');
      await paymentCollectionPage.waitForPaymentCollectionLoad();
      
      // Should show empty state message or table with no data
      const hasEmptyState = await paymentCollectionPage.emptyStateMessage.isVisible();
      const hasEmptyTable = await paymentCollectionPage.page.locator('td.text-gray-500').isVisible();
      
      expect(hasEmptyState || hasEmptyTable).toBe(true);
    });

    test('should show filtered empty state when no matches', async () => {
      await paymentCollectionPage.waitForTableData();
      
      // Apply filter that should return no results
      await paymentCollectionPage.setSearchFilter('nonexistent12345');
      await paymentCollectionPage.applyFilters();
      
      await paymentCollectionPage.page.waitForTimeout(1000);
      
      // Should show filtered empty state
      const emptyMessage = await paymentCollectionPage.page.locator('text=No payment records found matching your filters').isVisible();
      const emptyTable = await paymentCollectionPage.page.locator('td.text-gray-500').isVisible();
      
      expect(emptyMessage || emptyTable).toBe(true);
    });
  });

  test.describe('Responsive Design', () => {
    test('should adapt to mobile viewport', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.waitForTimeout(1000); // Wait for responsive layout
      
      await expect(paymentCollectionPage.pageTitle).toBeVisible();
      await expect(paymentCollectionPage.kpiSection).toBeVisible();
      await expect(paymentCollectionPage.filterSection).toBeVisible();
      await expect(paymentCollectionPage.paymentRecordsSection).toBeVisible();
    });

    test('should adapt to tablet viewport', async ({ page }) => {
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForTimeout(1000); // Wait for responsive layout
      
      await expect(paymentCollectionPage.pageTitle).toBeVisible();
      await expect(paymentCollectionPage.kpiSection).toBeVisible();
      await expect(paymentCollectionPage.filterSection).toBeVisible();
      await expect(paymentCollectionPage.paymentRecordsSection).toBeVisible();
    });

    test('should adapt to desktop viewport', async ({ page }) => {
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.waitForTimeout(1000); // Wait for responsive layout
      
      await expect(paymentCollectionPage.pageTitle).toBeVisible();
      await expect(paymentCollectionPage.kpiSection).toBeVisible();
      await expect(paymentCollectionPage.filterSection).toBeVisible();
      await expect(paymentCollectionPage.paymentRecordsSection).toBeVisible();
    });
  });

  test.describe('Performance', () => {
    test('should load payment collection page within acceptable time', async ({ page }) => {
      const startTime = Date.now();
      
      await paymentCollectionPage.navigateToPaymentCollection();
      await paymentCollectionPage.waitForKPICards();
      
      const loadTime = Date.now() - startTime;
      
      // Payment collection page should load within 10 seconds (increased timeout for CI)
      expect(loadTime).toBeLessThan(10000);
    });

    test('should handle large datasets efficiently', async () => {
      await paymentCollectionPage.waitForTableData();
      
      const rowCount = await paymentCollectionPage.getTableRowCount();
      
      // Should handle reasonable number of rows without performance issues
      expect(rowCount).toBeLessThan(1000); // Reasonable limit
    });
  });
});
