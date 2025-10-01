import { test, expect } from '@playwright/test';

test.describe('Working Dashboard Tests', () => {
  test('should login and access dashboard', async ({ page }) => {
    // Navigate to login page
    await page.goto('http://localhost:5173/login');
    await page.waitForLoadState('networkidle');
    
    // Click on super admin demo credentials
    await page.click('button:has-text("superadmin@parking.com")');
    
    // Wait for form to be filled
    await page.waitForTimeout(1000);
    
    // Submit the form
    await page.click('button[type="submit"]');
    
    // Wait for navigation to dashboard
    await page.waitForURL('**/dashboard', { timeout: 30000 });
    
    // Check if dashboard loaded
    await expect(page.locator('h1:has-text("Dashboard Overview")')).toBeVisible();
  });

  test('should display dashboard elements', async ({ page }) => {
    // Login first
    await page.goto('http://localhost:5173/login');
    await page.waitForLoadState('networkidle');
    
    await page.click('button:has-text("superadmin@parking.com")');
    await page.waitForTimeout(1000);
    await page.click('button[type="submit"]');
    await page.waitForURL('**/dashboard', { timeout: 30000 });
    
    // Check dashboard elements
    await expect(page.locator('h1:has-text("Dashboard Overview")')).toBeVisible();
    await expect(page.locator('text=Quick Actions')).toBeVisible();
    await expect(page.locator('text=Performance Metrics')).toBeVisible();
  });

  test('should display KPI cards', async ({ page }) => {
    // Login first
    await page.goto('http://localhost:5173/login');
    await page.waitForLoadState('networkidle');
    
    await page.click('button:has-text("superadmin@parking.com")');
    await page.waitForTimeout(1000);
    await page.click('button[type="submit"]');
    await page.waitForURL('**/dashboard', { timeout: 30000 });
    
    // Wait for KPI cards to load
    await page.waitForSelector('[data-testid="kpi-card"]', { timeout: 20000 });
    
    // Check KPI cards
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Total Income' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Total Sessions' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Revenue per Slot' })).toBeVisible();
  });
});
