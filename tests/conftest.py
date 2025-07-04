import pytest
from app import create_app, db
import json

@pytest.fixture(scope='module')
def app():
    """Create and configure a new app instance for each test module."""
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture(scope='module')
def client(app):
    """A test client for the app."""
    return app.test_client()

@pytest.fixture(scope='module')
def auth_headers(client):
    """Get auth headers for a test user."""
    # Register and login a user
    client.post('/auth/register',
                data=json.dumps(dict(
                    user_name='authuser',
                    user_email='auth@example.com',
                    user_password='password',
                    user_phone_no='5555555555'
                )),
                content_type='application/json')
    response = client.post('/auth/login',
                         data=json.dumps(dict(
                             user_email='auth@example.com',
                             user_password='password'
                         )),
                         content_type='application/json')
    access_token = json.loads(response.data)['access_token']
    return {'Authorization': f'Bearer {access_token}'} 