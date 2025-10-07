# Playwright Tests with Docker Backend Setup

This guide explains how to run Playwright tests against the Docker-based backend instead of the mock server.

## Prerequisites

1. **Docker and Docker Compose** installed and running
2. **Node.js** (v16 or higher) for running the React app
3. **Backend Docker containers** running and accessible

## Backend Setup

### 1. Start the Docker Backend
V
Navigate to the `Backend` directory and start the Docker containers:

```bash
cd Backend
docker-compose up --build -d
```

### 2. Initialize the Database

Run the database initialization commands:

```bash
# Option A: Using Flask-Migrate
docker-compose exec app flask db init
docker-compose exec app flask db migrate -m "Initial migration"
docker-compose exec app flask db upgrade

# Option B: Using SQL scripts
docker cp init_db.sql backend-db-1:/init_db.sql
docker exec -it backend-db-1 psql -U parking_user -d parking_db -f /init_db.sql

docker cp seed_data.sql backend-db-1:/seed_data.sql
docker exec -it backend-db-1 psql -U parking_user -d parking_db -f /seed_data.sql
```

### 3. Verify Backend is Running

Check that the backend is accessible:

- **Main API**: `http://localhost`
- **API Documentation**: `http://localhost/apidocs`
- **Health Check**: `http://localhost/health` (if available)

## Test Configuration Changes

The Playwright tests have been updated to work with the Docker backend:

### Updated API Endpoints

The tests now use the correct API endpoints for the Docker backend:

```javascript
export const apiEndpoints = {
  login: '/auth/login',
  dashboard: '/admin/sessions/details/all',
  adminManagement: '/admin/admin_lots/all',
  liveSessions: '/admin/sessions/details/all',
  paymentCollection: '/admin/total_due',
  dailyClosure: '/admin/closure',
  assignLot: '/admin/assign_lot',
  removeAssignment: '/admin/remove_assignment',
  checkin: '/admin/session/checkin',
  checkout: '/admin/session/checkout',
  finalizeClosure: '/admin/finalize_closure',
};
```

### Updated Test Credentials

The tests now use actual user credentials from the backend seed data:

```javascript
export const testCredentials = {
  superAdmin: {
    email: 'superadmin@parking.com',
    password: 'password123',
    role: 'super_admin'
  },
  admin: {
    email: 'admin10@parking.com',
    password: 'password123',
    role: 'admin'
  },
  invalid: {
    email: 'invalid@email.com',
    password: 'wrongpassword'
  }
};
```

## Available npm Scripts

The project includes comprehensive npm scripts for running tests:

### Basic Test Commands
- `npm test` - Run all tests (headless)
- `npm run test:headed` - Run all tests with browser visible
- `npm run test:debug` - Run all tests in debug mode
- `npm run test:ui` - Run all tests with Playwright UI

### Individual Test Suites
- `npm run test:login` - Run login tests only
- `npm run test:dashboard` - Run dashboard tests only
- `npm run test:admin-management` - Run admin management tests only
- `npm run test:payment-collection` - Run payment collection tests only
- `npm run test:daily-closure` - Run daily closure tests only
- `npm run test:live-sessions` - Run live sessions tests only
- `npm run test:settings` - Run settings tests only

### Headed Mode (Browser Visible)
- `npm run test:login:headed` - Login tests with browser visible
- `npm run test:dashboard:headed` - Dashboard tests with browser visible
- `npm run test:admin-management:headed` - Admin management tests with browser visible
- `npm run test:payment-collection:headed` - Payment collection tests with browser visible
- `npm run test:daily-closure:headed` - Daily closure tests with browser visible
- `npm run test:live-sessions:headed` - Live sessions tests with browser visible
- `npm run test:settings:headed` - Settings tests with browser visible

### Debug and UI Mode
- `npm run test:admin-management:debug` - Admin management tests in debug mode
- `npm run test:admin-management:ui` - Admin management tests with UI

### Report and Cleanup
- `npm run test:report` - Open the last HTML report
- `npm run test:fresh` - Clean and run tests with HTML report
- `npm run test:fresh:headed` - Clean and run tests with HTML report (headed)
- `npm run test:clean` - Clean test artifacts and reports

## Running Tests

### 1. Start the React App

In the `admin_react_app` directory:

```bash
cd admin_react_app
npm install
npm run dev
```

The React app should start on `http://localhost:5173`.

### 2. Run Playwright Tests

```bash
cd admin_react_app
npm test
```

### 3. Run Specific Test Suites

```bash
# Run only login tests
npm run test:login

# Run only dashboard tests
npm run test:dashboard

# Run only admin management tests
npm run test:admin-management

# Run only payment collection tests
npm run test:payment-collection

# Run only daily closure tests
npm run test:daily-closure

# Run only live sessions tests
npm run test:live-sessions

# Run only settings tests
npm run test:settings
```

### 4. Run Tests in Headed Mode

```bash
# Run all tests with browser visible
npm run test:headed

# Run specific test suites in headed mode
npm run test:login:headed
npm run test:dashboard:headed
npm run test:admin-management:headed
npm run test:payment-collection:headed
npm run test:daily-closure:headed
npm run test:live-sessions:headed
npm run test:settings:headed
```

### 5. Run Tests with Debug Mode

```bash
# Run all tests in debug mode
npm run test:debug

# Run specific test suites in debug mode
npm run test:admin-management:debug
```

### 6. Run Tests with UI Mode

```bash
# Run all tests with Playwright UI
npm run test:ui

# Run specific test suites with UI
npm run test:admin-management:ui
```

### 7. View Test Reports

```bash
# Open the last HTML report
npm run test:report

# Generate fresh HTML report
npm run test:fresh

# Generate fresh HTML report in headed mode
npm run test:fresh:headed
```

### 8. Clean Test Artifacts

```bash
# Clean previous test results and reports
npm run test:clean
```

## Test Data

The tests use the following data from the backend seed:

### Available Users

- **Super Admin**: `superadmin@parking.com` / `password123`
- **Admin Users**: `admin10@parking.com` through `admin19@parking.com` / `password123`
- **Regular Users**: `user20@parking.com` through `user29@parking.com` / `password123`

### Available Parking Lots

The backend seed data includes 10 parking lots with IDs 1-10, each with multiple floors, rows, and slots.

## Troubleshooting

### Backend Connection Issues

1. **Check Docker containers are running**:
   ```bash
   docker-compose ps
   ```

2. **Check backend logs**:
   ```bash
   docker-compose logs app
   ```

3. **Verify database connection**:
   ```bash
   docker-compose exec db psql -U parking_user -d parking_db -c "SELECT COUNT(*) FROM users;"
   ```

### Test Failures

1. **Authentication Issues**:
   - Verify the backend is running on `http://localhost`
   - Check that the test credentials match the seed data
   - Ensure JWT tokens are being generated correctly

2. **API Endpoint Issues**:
   - Verify API endpoints are accessible via `http://localhost/apidocs`
   - Check that the React app is configured to use the correct backend URL

3. **Data Issues**:
   - Ensure the database is properly seeded with test data
   - Check that parking lots and sessions exist in the database

### Performance Issues

1. **Slow Tests**:
   - The Docker backend may be slower than the mock server
   - Consider increasing timeouts in `playwright.config.js`
   - Use `npm run test:headed` for debugging slow tests
   - The config already uses `workers: 1` for stable execution

2. **Resource Usage**:
   - Docker containers consume more resources than the mock server
   - Consider stopping other Docker containers when running tests
   - Use `npm run test:clean` to free up disk space from test artifacts

## Configuration Files

### Playwright Configuration (`playwright.config.js`)

The configuration has been updated to:
- Remove mock server dependency
- Only start the React app on port 5173
- Expect the backend to be running separately on port 80

### Test Data (`utils/test-data.js`)

Updated to use:
- Correct API endpoints for Docker backend
- Actual user credentials from seed data
- Proper admin user email (`admin10@parking.com`)

### Page Objects

Updated to work with:
- Real backend API responses
- Actual data structures from the database
- Proper error handling for backend responses

## Migration from Mock Server

The following changes were made to migrate from mock server to Docker backend:

1. **Removed mock server** from `playwright.config.js`
2. **Updated API endpoints** to match backend routes
3. **Updated test credentials** to use real user data
4. **Updated test expectations** for real data vs mock data
5. **Updated page objects** to handle real API responses

## Best Practices

1. **Always start the backend first** before running tests
2. **Use npm scripts** instead of direct Playwright commands for consistency
3. **Use the same database state** for consistent test results
4. **Clean up test data** if tests create new data
5. **Run tests in serial mode** for tests that modify data (already configured)
6. **Use proper wait strategies** for async operations
7. **Use `npm run test:clean`** regularly to manage disk space
8. **Use `npm run test:headed`** for debugging failing tests
9. **Use `npm run test:debug`** for step-by-step debugging

## Next Steps

1. **Add more test data** to the backend seed if needed
2. **Implement test data cleanup** for tests that create data
3. **Add performance tests** for the real backend
4. **Implement CI/CD integration** with Docker backend
5. **Add API contract tests** to ensure frontend-backend compatibility
