import json
import pytest
import uuid

def test_user_registration(client):
    """
    GIVEN a Flask application configured for testing
    WHEN a POST request is sent to '/auth/register'
    THEN check that a '201' status code is returned and a new user is created.
    """
    response = client.post('/auth/register',
                           data=json.dumps(dict(
                               user_name='testuser',
                               user_email='test@example.com',
                               user_password='password',
                               user_phone_no='1234567890'
                           )),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['msg'] == 'User registered successfully'

def test_user_login(client):
    """
    GIVEN a registered user
    WHEN a POST request is sent to '/auth/login'
    THEN check that a '200' status code is returned and an access token is provided.
    """
    # First, register a user to ensure the user exists
    client.post('/auth/register',
                data=json.dumps(dict(
                    user_name='loginuser',
                    user_email='login@example.com',
                    user_password='password',
                    user_phone_no='0987654321'
                )),
                content_type='application/json')

    # Now, attempt to log in
    response = client.post('/auth/login',
                           data=json.dumps(dict(
                               user_email='login@example.com',
                               user_password='password'
                           )),
                           content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'access_token' in data 

def test_user_registration_with_role(client):
    """
    Test registration with explicit role (should default to 'user' if not admin with secret).
    """
    # Register as normal user (no role specified)
    response = client.post('/auth/register',
        data=json.dumps(dict(
            user_name='roleuser',
            user_email='roleuser@example.com',
            user_password='password',
            user_phone_no='1111111111'
        )),
        content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['role'] == 'user'

    # Attempt to register as admin without secret (should be forbidden)
    response = client.post('/auth/register',
        data=json.dumps(dict(
            user_name='fakeadmin',
            user_email='fakeadmin@example.com',
            user_password='password',
            user_phone_no='2222222222',
            role='admin'
        )),
        content_type='application/json')
    assert response.status_code == 403

    # Attempt to register as admin with correct secret (should also be forbidden)
    response = client.post('/auth/register',
        data=json.dumps(dict(
            user_name='realadmin',
            user_email='realadmin@example.com',
            user_password='password',
            user_phone_no='3333333333',
            role='admin',
            admin_secret='SUPER_SECRET_ADMIN_KEY'
        )),
        content_type='application/json')
    assert response.status_code == 403

def test_login_returns_role(client):
    """
    Test that login response and JWT include the correct role.
    """
    # Register a user
    client.post('/auth/register',
        data=json.dumps(dict(
            user_name='jwtroleuser',
            user_email='jwtrole@example.com',
            user_password='password',
            user_phone_no='4444444444'
        )),
        content_type='application/json')
    # Login
    response = client.post('/auth/login',
        data=json.dumps(dict(
            user_email='jwtrole@example.com',
            user_password='password'
        )),
        content_type='application/json')
    assert response.status_code == 200
    data = json.loads(response.data)
    assert 'role' in data
    assert data['role'] == 'user'
    # Optionally, decode JWT and check claims (requires PyJWT and secret) 

def register_user(client, role='user', email=None, phone=None, secret=None):
    data = {
        'user_name': f'{role}_user',
        'user_email': email or f'{role}_user@example.com',
        'user_password': 'password',
        'user_phone_no': phone or f'100000000{1 if role=="admin" else 2}',
        'user_address': 'Test Address',
    }
    if role == 'admin':
        data['role'] = 'admin'
        data['admin_secret'] = 'SUPER_SECRET_ADMIN_KEY'
    elif role == 'super_admin':
        data['super_admin_secret'] = 'SUPER_SECRET_SUPER_ADMIN_KEY'
    resp = client.post(
        '/auth/register_super_admin' if role == 'super_admin' else '/auth/register',
        data=json.dumps(data),
        content_type='application/json')
    return resp

def login_user(client, email, password='password'):
    resp = client.post('/auth/login', data=json.dumps({
        'user_email': email,
        'user_password': password
    }), content_type='application/json')
    return resp 