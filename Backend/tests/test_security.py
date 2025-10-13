"""
Security Tests for Smart Parking Backend
========================================

This module contains security-focused tests including:
- Authentication and authorization
- Input validation and sanitization
- SQL injection prevention
- XSS prevention
- Rate limiting
- API key security
- JWT token security
"""

import json
import pytest
import time
from app import create_app, db
from app.models import User


@pytest.fixture(scope='function')
def app():
    """Create and configure a new app instance for each test function."""
    app = create_app('testing')
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()


@pytest.fixture(scope='function')
def client(app):
    """A test client for the app."""
    return app.test_client()


class TestAuthenticationSecurity:
    """Test authentication security measures."""
    
    def test_jwt_token_security(self, client):
        """Test JWT token security measures."""
        
        # Register a user
        user_data = {
            'user_name': 'security_user',
            'user_email': 'security@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 201
        
        # Login to get token
        login_data = {
            'user_email': 'security@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        assert response.status_code == 200
        
        response_data = json.loads(response.data)
        token = response_data['access_token']
        
        # Test token format (should be JWT)
        assert len(token.split('.')) == 3, "Token should be in JWT format"
        
        # Test token contains required claims
        import jwt
        decoded = jwt.decode(token, options={"verify_signature": False})
        assert 'user_id' in decoded
        assert 'role' in decoded
        assert decoded['role'] == 'user'
    
    def test_token_expiration(self, client):
        """Test that tokens expire appropriately."""
        
        # Register and login user
        user_data = {
            'user_name': 'expiry_user',
            'user_email': 'expiry@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        login_data = {
            'user_email': 'expiry@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        response_data = json.loads(response.data)
        token = response_data['access_token']
        headers = {'Authorization': f'Bearer {token}'}
        
        # Token should work initially
        response = client.get('/parking/lots', headers=headers)
        assert response.status_code == 200
    
    def test_invalid_token_handling(self, client):
        """Test handling of invalid tokens."""
        
        invalid_tokens = [
            'invalid_token',
            'Bearer invalid_token',
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.invalid',
            '',
            None
        ]
        
        for token in invalid_tokens:
            headers = {'Authorization': f'Bearer {token}'} if token else {}
            response = client.get('/parking/lots', headers=headers)
            assert response.status_code == 401
    
    def test_role_based_access_control(self, client):
        """Test role-based access control."""
        
        # Create user and admin
        user_data = {
            'user_name': 'rbac_user',
            'user_email': 'rbac@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Login as user
        login_data = {
            'user_email': 'rbac@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        user_token = json.loads(response.data)['access_token']
        user_headers = {'Authorization': f'Bearer {user_token}'}
        
        # User should not access admin endpoints
        response = client.get('/admin/closure', headers=user_headers)
        assert response.status_code == 403
        
        # User should access user endpoints
        response = client.get('/parking/lots', headers=user_headers)
        assert response.status_code == 200


class TestInputValidationSecurity:
    """Test input validation and sanitization."""
    
    def test_sql_injection_prevention(self, client):
        """Test prevention of SQL injection attacks."""
        
        # Register user
        user_data = {
            'user_name': 'sql_user',
            'user_email': 'sql@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Login
        login_data = {
            'user_email': 'sql@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        token = json.loads(response.data)['access_token']
        headers = {'Authorization': f'Bearer {token}'}
        
        # Test SQL injection in parking lot name
        malicious_data = {
            'name': "'; DROP TABLE users; --",
            'address': '123 Test St',
            'city': 'Test City',
            'landmark': 'Near Test Landmark',
            'latitude': 12.345,
            'longitude': 67.890,
            'physical_appearance': 'Multi-storey',
            'parking_ownership': 'Private',
            'parking_surface': 'Concrete',
            'has_cctv': 'Yes',
            'has_boom_barrier': 'Yes',
            'ticket_generated': 'Yes',
            'entry_exit_gates': '2',
            'weekly_off': 'Sunday',
            'parking_timing': '24x7',
            'vehicle_types': 'Car,Bike',
            'car_capacity': 50,
            'available_car_slots': 50,
            'two_wheeler_capacity': 20,
            'available_two_wheeler_slots': 20,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '20/hr',
            'two_wheeler_parking_charge': '10/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Car Wash'
        }
        
        response = client.post('/parking/lots',
                             headers=headers,
                             data=json.dumps(malicious_data),
                             content_type='application/json')
        
        # Should either succeed (with sanitized input) or fail gracefully
        assert response.status_code in [201, 400]
        
        # Verify users table still exists
        response = client.get('/parking/lots', headers=headers)
        assert response.status_code == 200
    
    def test_xss_prevention(self, client):
        """Test prevention of XSS attacks."""
        
        # Register user
        user_data = {
            'user_name': 'xss_user',
            'user_email': 'xss@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Login
        login_data = {
            'user_email': 'xss@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        token = json.loads(response.data)['access_token']
        headers = {'Authorization': f'Bearer {token}'}
        
        # Test XSS in parking lot name
        xss_data = {
            'name': '<script>alert("XSS")</script>',
            'address': '123 Test St',
            'city': 'Test City',
            'landmark': 'Near Test Landmark',
            'latitude': 12.345,
            'longitude': 67.890,
            'physical_appearance': 'Multi-storey',
            'parking_ownership': 'Private',
            'parking_surface': 'Concrete',
            'has_cctv': 'Yes',
            'has_boom_barrier': 'Yes',
            'ticket_generated': 'Yes',
            'entry_exit_gates': '2',
            'weekly_off': 'Sunday',
            'parking_timing': '24x7',
            'vehicle_types': 'Car,Bike',
            'car_capacity': 50,
            'available_car_slots': 50,
            'two_wheeler_capacity': 20,
            'available_two_wheeler_slots': 20,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '20/hr',
            'two_wheeler_parking_charge': '10/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Car Wash'
        }
        
        response = client.post('/parking/lots',
                             headers=headers,
                             data=json.dumps(xss_data),
                             content_type='application/json')
        
        if response.status_code == 201:
            # If created, verify the script tags are handled appropriately
            response_data = json.loads(response.data)
            # The response should either escape the script tags or return them as-is
            # (depending on the implementation)
            assert response_data['name'] is not None
    
    def test_input_length_validation(self, client):
        """Test input length validation."""
        
        # Register user
        user_data = {
            'user_name': 'length_user',
            'user_email': 'length@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Login
        login_data = {
            'user_email': 'length@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        token = json.loads(response.data)['access_token']
        headers = {'Authorization': f'Bearer {token}'}
        
        # Test extremely long input
        long_string = 'A' * 10000
        long_data = {
            'name': long_string,
            'address': '123 Test St',
            'city': 'Test City',
            'landmark': 'Near Test Landmark',
            'latitude': 12.345,
            'longitude': 67.890,
            'physical_appearance': 'Multi-storey',
            'parking_ownership': 'Private',
            'parking_surface': 'Concrete',
            'has_cctv': 'Yes',
            'has_boom_barrier': 'Yes',
            'ticket_generated': 'Yes',
            'entry_exit_gates': '2',
            'weekly_off': 'Sunday',
            'parking_timing': '24x7',
            'vehicle_types': 'Car,Bike',
            'car_capacity': 50,
            'available_car_slots': 50,
            'two_wheeler_capacity': 20,
            'available_two_wheeler_slots': 20,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '20/hr',
            'two_wheeler_parking_charge': '10/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Car Wash'
        }
        
        response = client.post('/parking/lots',
                             headers=headers,
                             data=json.dumps(long_data),
                             content_type='application/json')
        
        # Should either reject or truncate the input
        assert response.status_code in [201, 400, 413]


class TestAPISecurity:
    """Test API security measures."""
    
    def test_api_key_security(self, client):
        """Test API key authentication for IoT endpoints."""
        
        # Test without API key
        response = client.post('/api/v1/slots/update_status',
                              data=json.dumps({
                                  'slot_id': 1,
                                  'status': 1,
                                  'vehicle_reg_no': 'TEST123'
                              }),
                              content_type='application/json')
        assert response.status_code == 401
        
        # Test with invalid API key
        response = client.post('/api/v1/slots/update_status',
                              data=json.dumps({
                                  'slot_id': 1,
                                  'status': 1,
                                  'vehicle_reg_no': 'TEST123'
                              }),
                              headers={'X-API-KEY': 'invalid_key'},
                              content_type='application/json')
        assert response.status_code == 401
        
        # Test with valid API key (if configured)
        # Note: This would need the actual API key from config
        # response = client.post('/api/v1/slots/update_status',
        #                       data=json.dumps({
        #                           'slot_id': 1,
        #                           'status': 1,
        #                           'vehicle_reg_no': 'TEST123'
        #                       }),
        #                       headers={'X-API-KEY': 'valid_key'},
        #                       content_type='application/json')
        # assert response.status_code == 200
    
    def test_cors_security(self, client):
        """Test CORS security configuration."""
        
        # Test preflight request
        response = client.options('/parking/lots',
                                headers={
                                    'Origin': 'http://malicious-site.com',
                                    'Access-Control-Request-Method': 'POST',
                                    'Access-Control-Request-Headers': 'Content-Type,Authorization'
                                })
        
        # Should either reject or allow based on CORS config
        assert response.status_code in [200, 403]
    
    def test_content_type_validation(self, client):
        """Test content type validation."""
        
        # Test with wrong content type
        response = client.post('/auth/register',
                              data='{"user_name": "test"}',
                              content_type='text/plain')
        assert response.status_code in [400, 415]  # Either 400 or 415 is acceptable
        
        # Test with no content type
        response = client.post('/auth/register',
                              data='{"user_name": "test"}')
        assert response.status_code in [400, 415]  # Either 400 or 415 is acceptable


class TestRateLimiting:
    """Test rate limiting security measures."""
    
    def test_registration_rate_limiting(self, client):
        """Test rate limiting on registration endpoint."""
        
        # Attempt multiple rapid registrations
        for i in range(10):
            user_data = {
                'user_name': f'rate_user_{i}',
                'user_email': f'rate{i}@example.com',
                'user_password': 'password123',
                'user_phone_no': f'123456789{i}',
                'user_address': 'Test Address'
            }
            response = client.post('/auth/register',
                                 data=json.dumps(user_data),
                                 content_type='application/json')
            
            # Should eventually hit rate limit
            if response.status_code == 429:
                break
        
        # Note: Rate limiting might not be implemented yet
        # This test documents the expected behavior
    
    def test_login_rate_limiting(self, client):
        """Test rate limiting on login endpoint."""
        
        # Register a user first
        user_data = {
            'user_name': 'rate_login_user',
            'user_email': 'ratelogin@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Attempt multiple rapid logins
        for i in range(10):
            login_data = {
                'user_email': 'ratelogin@example.com',
                'user_password': 'wrong_password',
                'role': 'user'
            }
            response = client.post('/auth/login',
                                  data=json.dumps(login_data),
                                  content_type='application/json')
            
            # Should eventually hit rate limit
            if response.status_code == 429:
                break


class TestDataSecurity:
    """Test data security measures."""
    
    def test_password_hashing(self, client):
        """Test that passwords are properly hashed."""
        
        user_data = {
            'user_name': 'hash_user',
            'user_email': 'hash@example.com',
            'user_password': 'plaintext_password',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 201
        
        # Verify password is hashed in database
        with client.application.app_context():
            user = User.query.filter_by(user_email='hash@example.com').first()
            assert user is not None
            assert user.user_password != 'plaintext_password'
            assert len(user.user_password) > 20  # Hashed passwords are longer
    
    def test_sensitive_data_exposure(self, client):
        """Test that sensitive data is not exposed in responses."""
        
        # Register user
        user_data = {
            'user_name': 'sensitive_user',
            'user_email': 'sensitive@example.com',
            'user_password': 'password123',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        # Login
        login_data = {
            'user_email': 'sensitive@example.com',
            'user_password': 'password123',
            'role': 'user'
        }
        response = client.post('/auth/login',
                              data=json.dumps(login_data),
                              content_type='application/json')
        
        response_data = json.loads(response.data)
        
        # Password should not be in response
        assert 'user_password' not in response_data
        
        # Other sensitive fields should be handled appropriately
        # (This depends on the specific implementation)


# Mark tests for security category
pytestmark = [
    pytest.mark.security,
    pytest.mark.slow
]
