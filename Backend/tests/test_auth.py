import json

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