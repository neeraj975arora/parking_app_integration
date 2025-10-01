import { test, expect } from '@playwright/test';

test.describe('Simple Dashboard Tests', () => {
  test('should load dashboard page', async ({ page }) => {
    // Navigate directly to dashboard
    await page.goto('http://localhost:5173/dashboard');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Check if we're redirected to login (expected behavior)
    const currentUrl = page.url();
    if (currentUrl.includes('/login')) {
      // This is expected - dashboard should redirect to login if not authenticated
      expect(currentUrl).toContain('/login');
    } else {
      // If we're on dashboard, check for basic elements
      await expect(page.locator('h1')).toBeVisible();
    }
  });

  test('should load login page', async ({ page }) => {
    await page.goto('http://localhost:5173/login');
    await page.waitForLoadState('networkidle');
    
    // Check for login form elements
    await expect(page.locator('input[type="email"]')).toBeVisible();
    await expect(page.locator('input[type="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });
});
