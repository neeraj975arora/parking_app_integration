import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true, // Enable parallel execution in CI
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : 1, // Use 2 workers in CI
  timeout: 180000, // 3 minutes per test in CI
  expect: {
    timeout: 30000, // 30 seconds for assertions in CI
  },
  reporter: [
    ['html', { outputFolder: '../test-results/playwright-report' }],
    ['json', { outputFile: '../test-results/results.json' }],
    ['junit', { outputFile: '../test-results/results.xml' }],
    ['list']
  ],
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: { mode: 'only-on-failure', fullPage: true },
    video: { mode: 'retain-on-failure', size: { width: 1280, height: 720 } },
    actionTimeout: 30000, // Increased for CI stability
    navigationTimeout: 120000, // 2 minutes for navigation in CI
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  // Don't start web server in CI - it should be started by the workflow
  webServer: process.env.CI ? undefined : [
    {
      command: 'npm run dev',
      port: 5173,
      reuseExistingServer: !process.env.CI,
    },
  ],
});
