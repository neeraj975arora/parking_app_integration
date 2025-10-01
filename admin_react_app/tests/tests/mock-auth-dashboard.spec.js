import { test, expect } from '@playwright/test';

test.describe('Mock Auth Dashboard Tests', () => {
  test.beforeEach(async ({ page }) => {
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
  });

  test('should display dashboard page elements', async ({ page }) => {
    await expect(page.locator('h1:has-text("Dashboard Overview")')).toBeVisible();
    await expect(page.locator('text=Welcome back')).toBeVisible();
    await expect(page.locator('text=Quick Actions')).toBeVisible();
    await expect(page.locator('text=Performance Metrics')).toBeVisible();
  });

  test('should display KPI cards', async ({ page }) => {
    // Wait for KPI cards to load
    await page.waitForSelector('[data-testid="kpi-card"]', { timeout: 20000 });
    
    // Check KPI cards are visible
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Total Income' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Total Sessions' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Revenue per Slot' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Active Participants' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Average Session Time' })).toBeVisible();
    await expect(page.locator('[data-testid="kpi-card"]').filter({ hasText: 'Occupancy Rate' })).toBeVisible();
  });

  test('should display session overview section', async ({ page }) => {
    await expect(page.locator('text=Session Overview')).toBeVisible();
    
    // Check session counts
    const totalSessions = page.locator('text=Total Sessions').locator('..').locator('span').last();
    const activeSessions = page.locator('text=Active Sessions').locator('..').locator('span').last();
    const completedSessions = page.locator('text=Completed Sessions').locator('..').locator('span').last();
    
    await expect(totalSessions).toBeVisible();
    await expect(activeSessions).toBeVisible();
    await expect(completedSessions).toBeVisible();
  });

  test('should display system information section', async ({ page }) => {
    await expect(page.locator('text=System Information')).toBeVisible();
    
    // Check system metrics
    const totalParkingSlots = page.locator('text=Total Parking Slots').locator('..').locator('span').last();
    const adminLotsCount = page.locator('text=Admin Lots').locator('..').locator('span').last();
    const dataSource = page.locator('text=Data Source').locator('..').locator('span').last();
    
    await expect(totalParkingSlots).toBeVisible();
    await expect(adminLotsCount).toBeVisible();
    await expect(dataSource).toBeVisible();
  });

  test('should display quick actions', async ({ page }) => {
    await expect(page.locator('text=Quick Actions')).toBeVisible();
    
    // Check quick action buttons
    await expect(page.locator('button').filter({ hasText: 'Live Sessions' })).toBeVisible();
    await expect(page.locator('button').filter({ hasText: 'Payment Collection' })).toBeVisible();
    await expect(page.locator('button').filter({ hasText: 'Daily Closure' })).toBeVisible();
    await expect(page.locator('button').filter({ hasText: 'Admin Management' })).toBeVisible();
    await expect(page.locator('button').filter({ hasText: 'Settings' })).toBeVisible();
  });

  test('should show user role correctly', async ({ page }) => {
    const roleElement = page.locator('text=Role:').locator('..').locator('span').last();
    await expect(roleElement).toBeVisible();
    
    const roleText = await roleElement.textContent();
    expect(roleText.toLowerCase()).toContain('super admin');
  });
});
