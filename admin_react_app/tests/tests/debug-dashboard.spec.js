import { test, expect } from '@playwright/test';

test.describe('Debug Dashboard Tests', () => {
  test('debug dashboard loading', async ({ page }) => {
    // Mock the authentication by setting localStorage directly
    await page.goto('http://localhost:5173/login');
    
    // Set mock authentication data in localStorage
    await page.evaluate(() => {
      localStorage.setItem('auth_token', 'mock-token-123');
      localStorage.setItem('auth_user', JSON.stringify({
        user_id: '1',
        username: 'Super Admin',
        user_email: 'superadmin@parking.com',
        role: 'super_admin',
        user_phone_no: '1234567890',
        user_address: 'Test Address'
      }));
    });
    
    // Navigate to dashboard
    await page.goto('http://localhost:5173/dashboard');
    await page.waitForLoadState('networkidle');
    
    // Take a screenshot to see what's on the page
    await page.screenshot({ path: 'debug-dashboard.png' });
    
    // Get page content
    const pageContent = await page.content();
    console.log('Page content:', pageContent.substring(0, 1000));
    
    // Check what's actually on the page
    const title = await page.locator('h1').first().textContent().catch(() => 'No h1 found');
    console.log('Page title:', title);
    
    // Check for any error messages
    const errorMessages = await page.locator('text=Error, text=Failed, text=Connection').allTextContents();
    console.log('Error messages:', errorMessages);
    
    // Check for loading states
    const loadingElements = await page.locator('.animate-pulse').count();
    console.log('Loading elements count:', loadingElements);
  });
});
