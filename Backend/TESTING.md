# Smart Parking Backend - Testing Guide

This document provides a comprehensive guide to testing the Smart Parking Backend system.

## Table of Contents

1. [Test Structure](#test-structure)
2. [Running Tests](#running-tests)
3. [Test Categories](#test-categories)
4. [CI/CD Integration](#cicd-integration)
5. [Test Data Management](#test-data-management)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)
8. [Troubleshooting](#troubleshooting)

## Test Structure

The test suite is organized as follows:

```
Backend/
├── tests/
│   ├── conftest.py              # Test configuration and fixtures
│   ├── test_auth.py             # Authentication tests
│   ├── test_parking.py          # Parking management tests
│   ├── test_admin_api.py        # Admin API tests
│   ├── test_integration.py      # Integration tests
│   ├── test_security.py         # Security tests
│   └── test_config.py           # Test utilities and factories
├── run_tests.py                 # Test runner script
├── pytest.ini                  # Pytest configuration
└── .github/workflows/
    └── backend-tests.yml        # GitHub Actions workflow
```

## Running Tests

### Using the Test Runner Script

The `run_tests.py` script provides a convenient way to run different types of tests:

```bash
# Run all tests
python run_tests.py --type all --verbose --coverage

# Run only unit tests
python run_tests.py --type unit --verbose

# Run integration tests
python run_tests.py --type integration --verbose --coverage

# Run security tests
python run_tests.py --type security --verbose

# Run performance tests
python run_tests.py --type performance --verbose

# Run a specific test file
python run_tests.py --type specific --test tests/test_auth.py --verbose

# Run linting checks
python run_tests.py --lint

# Generate test report
python run_tests.py --report
```

### Using Docker (Recommended)

For the most consistent testing environment, use Docker:

```bash
# Build and start services
docker-compose up --build -d

# Run all tests
docker-compose exec app pytest

# Run specific test categories
docker-compose exec app pytest -m unit
docker-compose exec app pytest -m integration
docker-compose exec app pytest -m security

# Run with coverage
docker-compose exec app pytest --cov=app --cov-report=html

# Run end-to-end tests
docker-compose exec app python e2e_test.py
```

### Using pytest directly

```bash
# Install dependencies
pip install -r app/requirements.txt

# Run all tests
pytest tests/ -v

# Run specific test file
pytest tests/test_auth.py -v

# Run tests with coverage
pytest tests/ --cov=app --cov-report=html

# Run tests by category
pytest -m unit
pytest -m integration
pytest -m security
```

## Test Categories

### 1. Unit Tests (`test_auth.py`, `test_parking.py`, `test_admin_api.py`)

**Purpose**: Test individual components in isolation.

**Coverage**:
- Authentication and authorization
- Parking lot CRUD operations
- Admin management functions
- Data validation
- Error handling

**Run with**: `pytest -m unit`

### 2. Integration Tests (`test_integration.py`)

**Purpose**: Test complete workflows and component interactions.

**Coverage**:
- Full user registration and parking workflows
- Admin workflows (lot assignment, session management)
- IoT device integration
- Database transactions
- API endpoint integration
- Error handling and edge cases
- Performance and load testing

**Run with**: `pytest -m integration`

### 3. Security Tests (`test_security.py`)

**Purpose**: Test security measures and vulnerability prevention.

**Coverage**:
- Authentication and authorization security
- Input validation and sanitization
- SQL injection prevention
- XSS prevention
- Rate limiting
- API key security
- JWT token security
- Data security

**Run with**: `pytest -m security`

### 4. End-to-End Tests (`e2e_test.py`)

**Purpose**: Test the complete system in a production-like environment.

**Coverage**:
- Full system workflows
- Database integration
- API endpoint functionality
- Error scenarios
- Performance under load

**Run with**: `python e2e_test.py`

## CI/CD Integration

### GitHub Actions Workflow

The `.github/workflows/backend-tests.yml` file defines a comprehensive CI/CD pipeline:

1. **Unit Tests**: Fast, isolated component tests
2. **Integration Tests**: Workflow and interaction tests
3. **End-to-End Tests**: Full system tests with Docker
4. **Security Tests**: Security vulnerability scanning
5. **Performance Tests**: Load and performance testing
6. **Code Quality**: Linting and formatting checks
7. **Database Tests**: Database migration and constraint tests
8. **Regression Tests**: Comprehensive test suite

### Workflow Triggers

- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Daily scheduled runs at 2 AM UTC
- Manual triggers

### Test Reports

The workflow generates:
- Test coverage reports
- Security scan results
- Performance benchmarks
- Code quality metrics

## Test Data Management

### Test Data Factory

The `TestDataFactory` class provides methods to create consistent test data:

```python
from tests.test_config import TestDataFactory

# Create user data
user_data = TestDataFactory.create_user_data(role='user')

# Create parking lot data
lot_data = TestDataFactory.create_parking_lot_data()

# Create session data
session_data = TestDataFactory.create_session_data()
```

### Database Fixtures

Tests use isolated database fixtures:

```python
@pytest.fixture(scope='function')
def app():
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()
```

### Test Environment Setup

```python
# Set test environment variables
os.environ['FLASK_ENV'] = 'testing'
os.environ['DATABASE_URL'] = 'sqlite:///test.db'
os.environ['JWT_SECRET_KEY'] = 'test-secret-key'
os.environ['RPI_API_KEY'] = 'test-api-key'
```

## Performance Testing

### Load Testing

Integration tests include performance scenarios:

```python
def test_bulk_operations(self, client, auth_headers):
    """Test bulk operations performance."""
    # Create multiple floors, rows, and slots
    # Measure performance metrics
```

### Benchmarking

Use pytest-benchmark for performance measurement:

```bash
pytest tests/test_integration.py::TestPerformanceAndLoad --benchmark-only
```

### Performance Metrics

- Response time thresholds
- Memory usage limits
- Database query performance
- Concurrent operation handling

## Security Testing

### Authentication Security

- JWT token validation
- Token expiration handling
- Role-based access control
- Session management

### Input Validation

- SQL injection prevention
- XSS attack prevention
- Input length validation
- Data type validation

### API Security

- API key authentication
- CORS configuration
- Content type validation
- Rate limiting

### Data Security

- Password hashing
- Sensitive data exposure
- Database security
- Encryption

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   ```bash
   # Check database service
   docker-compose ps
   
   # Restart database
   docker-compose restart db
   ```

2. **Test Environment Issues**
   ```bash
   # Clean test database
   docker-compose exec app flask db drop_all
   docker-compose exec app flask db create_all
   ```

3. **Permission Errors**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER .
   chmod +x run_tests.py
   ```

4. **Import Errors**
   ```bash
   # Install dependencies
   pip install -r app/requirements.txt
   
   # Check Python path
   export PYTHONPATH="${PYTHONPATH}:$(pwd)"
   ```

### Debug Mode

Run tests in debug mode for detailed output:

```bash
pytest tests/ -v -s --tb=long
```

### Test Coverage

Generate detailed coverage reports:

```bash
pytest tests/ --cov=app --cov-report=html --cov-report=xml
```

### Logging

Enable debug logging for tests:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Data Cleanup**: Clean up test data after each test
3. **Mocking**: Use mocks for external dependencies
4. **Assertions**: Use specific assertions with clear messages
5. **Coverage**: Aim for high test coverage (>80%)
6. **Performance**: Keep unit tests fast (<1 second each)
7. **Documentation**: Document test purpose and scenarios
8. **Maintenance**: Keep tests updated with code changes

## Test Metrics

### Coverage Targets

- **Unit Tests**: >90% line coverage
- **Integration Tests**: >80% line coverage
- **Security Tests**: >95% security scenario coverage
- **Overall**: >85% combined coverage

### Performance Targets

- **Unit Tests**: <1 second per test
- **Integration Tests**: <5 seconds per test
- **End-to-End Tests**: <30 seconds total
- **API Response Time**: <200ms average

### Quality Gates

- All unit tests must pass
- All integration tests must pass
- Security tests must pass
- Code coverage must meet targets
- No critical security vulnerabilities
- Performance benchmarks must pass

## Contributing

When adding new tests:

1. Follow the existing test structure
2. Use appropriate test categories
3. Add proper documentation
4. Include both positive and negative test cases
5. Update this guide if needed
6. Ensure tests are maintainable and readable
