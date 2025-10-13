## Playwright Test Setup and CI Guide

> **⚠️ Important**: This project now uses Docker backend instead of mock server. See [DOCKER_BACKEND_TEST_SETUP.md](./DOCKER_BACKEND_TEST_SETUP.md) for the complete setup guide.

### Run tests locally (via package.json scripts)

Prerequisites:
- Node.js LTS installed
- Project dependencies installed: `npm install`
- **Docker backend running** (see Docker setup guide)

To install Playwrite if needed:
```
sudo npx playwright install-deps
             or
npx playwright install --with-deps
```

Common commands:
```
# Run the whole suite (headless)
npm test

# Run with UI test runner
npm run test:ui

# Run headed (browser visible)
npm run test:headed

# Clean previous reports and run fresh
npm run test:fresh

# Open the last HTML report
npm run test:report

# Run a specific page suite
npm run test:login
npm run test:dashboard
npm run test:payment-collection
npm run test:admin-management
npm run test:daily-closure
npm run test:live-sessions
npm run test:settings
```

Notes:
- The React app is auto-started by Playwright config (Vite app on port 5173).
- The Docker backend must be running separately on port 80.
- If ports are busy, stop other instances or kill the processes before running tests.

### Run a single page suite headed and choose browser

Examples (visible browser, pick project/browser, filter tests):
```
# Run a single suite headed on Chromium
npx playwright test tests/tests/dashboard.spec.js --headed --project=chromium

# Run a specific test within a suite (by title)
npx playwright test tests/tests/dashboard.spec.js -g "should display KPI values" --headed --project=chromium

# Open Inspector for step-by-step debugging (implies headed)
PWDEBUG=1 npx playwright test tests/tests/payment-collection.spec.js -g "open and close modal" --project=chromium

# Use the predefined npm scripts (headed per page)
npm run test:dashboard:headed
npm run test:payment-collection:headed
npm run test:admin-management:headed
npm run test:daily-closure:headed
npm run test:live-sessions:headed
npm run test:settings:headed

# Check Playwright and browser versions
npx playwright --version
node --input-type=module -e "import { chromium } from '@playwright/test'; const b = await chromium.launch(); console.log(b.version()); await b.close();"
```

### Debug and Clean

Debug locally:
```
# Open Playwright Inspector (interactive, step-by-step)
npm run test:debug

# Equivalent with env var (also implies headed)
PWDEBUG=1 npx playwright test tests/tests/login.spec.js -g "should login successfully as super admin"

# Show the last HTML report
npm run test:report
```

Use traces, screenshots, and videos:
- Traces are enabled on first retry per config (`trace: on-first-retry`).
- After a failure, open the HTML report and view the trace, screenshots, and videos for failing tests.

Clean artifacts:
```
# Remove prior reports and artifacts
npm run test:clean

# Clean then run fresh
npm run test:fresh
```

### GitHub Actions (CI) setup

1) Add Playwright GitHub Action workflow file at `.github/workflows/playwright.yml`:

```
name: E2E Tests (Playwright)

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright Browsers
        run: npx playwright install --with-deps

      - name: Run Playwright tests
        env:
          CI: true
        run: npm test

      - name: Upload HTML report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-html-report
          path: test-results/playwright-report

      - name: Upload raw results (json/junit)
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-raw-results
          path: test-results
```

2) Commit and push. The workflow will:
- Install Node and dependencies
- Install Playwright browsers
- Run `npm test` (headless)
- Upload HTML and raw reports as artifacts

### Tips for CI stability
- We’ve configured `workers: 1` and `fullyParallel: false` in `tests/playwright.config.js` for deterministic runs.
- Keep tests idempotent and avoid cross-test state; per-test storage cleanup is already implemented.
- If a port clash occurs in CI, ensure no other services bind to 5173/3001 in parallel jobs.
