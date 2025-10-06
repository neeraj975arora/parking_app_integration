import pytest
from app import create_app, db
import json
import logging
# Set up logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("test_debug.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)
@pytest.fixture(scope='function')
def app():
    """Create and configure a new app instance for each test function."""
    logger.info("Creating test app instance")
    app = create_app('testing')
    with app.app_context():
        logger.info("Creating database tables")
        db.create_all()
        yield app
        logger.info("Dropping database tables")
        db.drop_all()
@pytest.fixture(scope='function')
def client(app):
    """A test client for the app."""
    logger.info("Creating test client")
    return app.test_client()
@pytest.fixture(scope='function')
def auth_headers(client):
    """Get auth headers for a test user."""
    logger.info("Setting up auth headers")
    # Register a user
    logger.debug("Attempting user registration")
    register_data = dict(
        user_name='authuser',
        user_email='auth@example.com',
        user_password='password',
        user_phone_no='5555555555'
    )
    reg_response = client.post('/auth/register',
                data=json.dumps(register_data),
                content_type='application/json')
    logger.debug(f"Registration response status: {reg_response.status_code}")
    logger.debug(f"Registration response data: {reg_response.data}")
    # Login the user
    logger.debug("Attempting user login")
    login_data = dict(
        user_email='auth@example.com',  # Use correct field name
        user_password='password',       # Use correct field name
        role='user'                     # Added role field
    )
    response = client.post('/auth/login',
                         data=json.dumps(login_data),
                         content_type='application/json')
    logger.debug(f"Login response status: {response.status_code}")
    logger.debug(f"Login response data: {response.data}")
    # Check if login was successful
    if response.status_code != 200:
        logger.error(f"Login failed with status {response.status_code}")
        logger.error(f"Response data: {response.data}")
        pytest.fail(f"Login failed with status {response.status_code}: {response.data}")
    try:
        # Parse the response
        response_data = json.loads(response.data)
        access_token = response_data['access_token']
        logger.debug("Successfully extracted access token")
        return {'Authorization': f'Bearer {access_token}'}
    except KeyError:
        logger.error(f"Access token not found in response: {response.data}")
        pytest.fail("Access token not found in login response")
    except json.JSONDecodeError:
        logger.error(f"Invalid JSON response: {response.data}")
        pytest.fail("Invalid JSON response from login endpoint")