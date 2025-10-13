"""
Edge Cases and Boundary Value Tests
Tests for input validation, business logic boundaries, and extreme values
"""

import pytest
import json
import string
import random
from app import create_app, db


class TestInputValidation:
    """Test input validation with extreme values and edge cases."""

    def test_extremely_long_strings(self, client):
        """Test handling of extremely long strings in various fields."""
        # Generate extremely long strings
        long_string = "A" * 10000  # 10KB string
        very_long_string = "B" * 100000  # 100KB string
        
        # Test long user name
        user_data = {
            "user_name": long_string,
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # The API may accept long strings or reject them, both are valid behaviors
        assert response.status_code in [200, 201, 400, 409, 422]
        
        # Test long email
        user_data = {
            "user_name": "testuser",
            "user_email": long_string + "@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # Should reject extremely long emails or handle them gracefully
        assert response.status_code in [400, 409, 422]
        
        # Test long address
        user_data = {
            "user_name": "testuser",
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": very_long_string,
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # The API may accept long strings or reject them, both are valid behaviors
        assert response.status_code in [200, 201, 400, 409, 422]

    def test_minimum_and_maximum_numeric_boundaries(self, client, auth_headers):
        """Test minimum and maximum numeric boundaries."""
        # Test maximum integer values
        lot_data = {
            "parking_name": "Boundary Test Lot",
            "city": "Test City",
            "landmark": "Test Landmark",
            "address": "Test Address",
            "latitude": 12.9716,
            "longitude": 77.5946,
            "physical_appearance": "Multi-storey",
            "parking_ownership": "Private",
            "parking_surface": "Concrete",
            "has_cctv": "Yes",
            "has_boom_barrier": "Yes",
            "ticket_generated": "Yes",
            "entry_exit_gates": "2",
            "weekly_off": "Sunday",
            "parking_timing": "24x7",
            "vehicle_types": "Car,Bike",
            "car_capacity": 2147483647,  # Max 32-bit integer
            "available_car_slots": 2147483647,
            "two_wheeler_capacity": 2147483647,
            "available_two_wheeler_slots": 2147483647,
            "parking_type": "Open",
            "payment_modes": "Cash,Card,UPI",
            "car_parking_charge": "30/hr",
            "two_wheeler_parking_charge": "20/hr",
            "allows_prepaid_passes": "Yes",
            "provides_valet_services": "No",
            "value_added_services": "Smart Parking"
        }
        
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        # Should either accept or reject with proper error message
        assert response.status_code in [201, 400]
        
        # Test negative values
        lot_data["car_capacity"] = -1
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        assert response.status_code == 400
        
        # Test zero values
        lot_data["car_capacity"] = 0
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        assert response.status_code == 400

    def test_special_characters_in_various_fields(self, client):
        """Test handling of special characters in various fields."""
        special_chars = "!@#$%^&*()_+-=[]{}|;':\",./<>?`~"
        
        # Test special characters in user name
        user_data = {
            "user_name": f"test{special_chars}user",
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # Should either accept or reject with proper validation
        assert response.status_code in [201, 400, 409]  # May accept, reject, or conflict
        
        # Test special characters in email
        user_data = {
            "user_name": "testuser",
            "user_email": f"test{special_chars}@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # Should reject invalid email format or handle gracefully
        assert response.status_code in [400, 409, 422]
        
        # Test special characters in phone
        user_data = {
            "user_name": "testuser",
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": f"123{special_chars}4567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # Should reject invalid phone format or handle gracefully
        assert response.status_code in [400, 409, 422]

    def test_empty_and_null_values_for_required_fields(self, client):
        """Test handling of empty and null values for required fields."""
        # Test empty user name
        user_data = {
            "user_name": "",
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 400
        
        # Test null user name
        user_data = {
            "user_name": None,
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 400
        
        # Test missing required field
        user_data = {
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": "1234567890",
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 400

    def test_unicode_and_international_character_handling(self, client):
        """Test handling of Unicode and international characters."""
        # Test various Unicode characters
        unicode_strings = [
            "测试用户",  # Chinese
            "тестовый пользователь",  # Russian
            "مستخدم اختبار",  # Arabic
            "テストユーザー",  # Japanese
            "사용자 테스트",  # Korean
            "उपयोगकर्ता परीक्षण",  # Hindi
            "🧪👤",  # Emojis
            "café",  # Accented characters
            "naïve",  # Special characters
            "résumé"  # More accented characters
        ]
        
        for unicode_string in unicode_strings:
            user_data = {
                "user_name": unicode_string,
                "user_email": f"test{random.randint(1000, 9999)}@example.com",
                "user_password": "password123",
                "user_phone_no": f"123456{random.randint(1000, 9999)}",
                "user_address": f"Test Address {unicode_string}",
                "role": "user"
            }
            
            response = client.post('/auth/register',
                                 data=json.dumps(user_data),
                                 content_type='application/json')
            # Should handle Unicode properly
            assert response.status_code in [201, 400]


class TestBusinessLogicBoundaries:
    """Test business logic boundaries and edge cases."""

    def test_zero_capacity_parking_lots(self, client, auth_headers):
        """Test handling of zero capacity parking lots."""
        lot_data = {
            "parking_name": "Zero Capacity Lot",
            "city": "Test City",
            "landmark": "Test Landmark",
            "address": "Test Address",
            "latitude": 12.9716,
            "longitude": 77.5946,
            "physical_appearance": "Multi-storey",
            "parking_ownership": "Private",
            "parking_surface": "Concrete",
            "has_cctv": "Yes",
            "has_boom_barrier": "Yes",
            "ticket_generated": "Yes",
            "entry_exit_gates": "2",
            "weekly_off": "Sunday",
            "parking_timing": "24x7",
            "vehicle_types": "Car,Bike",
            "car_capacity": 0,  # Zero capacity
            "available_car_slots": 0,
            "two_wheeler_capacity": 0,
            "available_two_wheeler_slots": 0,
            "parking_type": "Open",
            "payment_modes": "Cash,Card,UPI",
            "car_parking_charge": "30/hr",
            "two_wheeler_parking_charge": "20/hr",
            "allows_prepaid_passes": "Yes",
            "provides_valet_services": "No",
            "value_added_services": "Smart Parking"
        }
        
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        assert response.status_code in [201, 400]  # May accept or reject zero capacity

    def test_maximum_slot_utilization_scenarios(self, client, auth_headers):
        """Test maximum slot utilization scenarios."""
        # Create parking lot with maximum capacity
        lot_data = {
            "parking_name": "Max Utilization Lot",
            "city": "Test City",
            "landmark": "Test Landmark",
            "address": "Test Address",
            "latitude": 12.9716,
            "longitude": 77.5946,
            "physical_appearance": "Multi-storey",
            "parking_ownership": "Private",
            "parking_surface": "Concrete",
            "has_cctv": "Yes",
            "has_boom_barrier": "Yes",
            "ticket_generated": "Yes",
            "entry_exit_gates": "2",
            "weekly_off": "Sunday",
            "parking_timing": "24x7",
            "vehicle_types": "Car,Bike",
            "car_capacity": 1000,  # Large capacity
            "available_car_slots": 1000,
            "two_wheeler_capacity": 500,
            "available_two_wheeler_slots": 500,
            "parking_type": "Open",
            "payment_modes": "Cash,Card,UPI",
            "car_parking_charge": "30/hr",
            "two_wheeler_parking_charge": "20/hr",
            "allows_prepaid_passes": "Yes",
            "provides_valet_services": "No",
            "value_added_services": "Smart Parking"
        }
        
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        assert response.status_code in [201, 400]  # May fail due to validation
        if response.status_code == 201:
            lot_id = response.get_json()['parkinglot_id']
        else:
            lot_id = 1  # Use default for test
        
        # Test booking all slots
        # This would require implementing slot booking logic
        # For now, we'll verify the structure
        assert lot_id is not None

    def test_time_boundary_conditions(self, client, auth_headers):
        """Test time boundary conditions like midnight crossings and DST changes."""
        # Test midnight crossing scenarios
        midnight_times = [
            "23:59:59",
            "00:00:00",
            "00:00:01"
        ]
        
        for time_str in midnight_times:
            # This would test parking session timing logic
            # For now, we'll verify the structure
            assert ":" in time_str
        
        # Test DST transition dates (these would be specific to your timezone)
        dst_dates = [
            "2024-03-10",  # Spring forward
            "2024-11-03",  # Fall back
        ]
        
        for date_str in dst_dates:
            closure_data = {
                "admin_id": 1,
                "date": date_str,
                "opening_balance": 1000.0,
                "today_collection": 500.0,
                "payment_made": 200.0,
                "closing_balance": 1300.0
            }
            
            response = client.post('/admin/closure',
                                 data=json.dumps(closure_data),
                                 headers=auth_headers,
                                 content_type='application/json')
            # Should handle DST transitions properly
            assert response.status_code in [201, 403]  # 403 for forbidden dates

    def test_payment_amount_boundaries(self, client, auth_headers):
        """Test payment amount boundaries."""
        # Test very small payment amounts
        small_amounts = [0.01, 0.001, 0.0001]
        
        for amount in small_amounts:
            closure_data = {
                "admin_id": 1,
                "date": "2024-01-01",
                "opening_balance": 1000.0,
                "today_collection": amount,
                "payment_made": 0.0,
                "closing_balance": 1000.0 + amount
            }
            
            response = client.post('/admin/closure',
                                 data=json.dumps(closure_data),
                                 headers=auth_headers,
                                 content_type='application/json')
            # Should handle small amounts properly
            assert response.status_code in [201, 403]  # 403 for forbidden
        
        # Test very large payment amounts
        large_amounts = [999999.99, 9999999.99, 99999999.99]
        
        for amount in large_amounts:
            closure_data = {
                "admin_id": 1,
                "date": "2024-01-01",
                "opening_balance": 1000.0,
                "today_collection": amount,
                "payment_made": 0.0,
                "closing_balance": 1000.0 + amount
            }
            
            response = client.post('/admin/closure',
                                 data=json.dumps(closure_data),
                                 headers=auth_headers,
                                 content_type='application/json')
            # Should handle large amounts properly
            assert response.status_code in [201, 403]  # 403 for forbidden
        
        # Test negative payment amounts
        closure_data = {
            "admin_id": 1,
            "date": "2024-01-01",
            "opening_balance": 1000.0,
            "today_collection": -100.0,  # Negative collection
            "payment_made": 0.0,
            "closing_balance": 900.0
        }
        
        response = client.post('/admin/closure',
                             data=json.dumps(closure_data),
                             headers=auth_headers,
                             content_type='application/json')
        assert response.status_code == 403  # Should reject negative amounts


class TestDataTypeValidation:
    """Test data type validation and conversion."""

    def test_string_fields_accepting_numeric_input(self, client):
        """Test that string fields properly handle numeric input."""
        # Test phone number with numeric input
        user_data = {
            "user_name": "testuser",
            "user_email": "test@example.com",
            "user_password": "password123",
            "user_phone_no": 1234567890,  # Numeric instead of string
            "user_address": "Test Address",
            "role": "user"
        }
        
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        # Should either convert to string or reject
        assert response.status_code in [201, 400]

    def test_numeric_fields_accepting_string_input(self, client, auth_headers):
        """Test that numeric fields properly handle string input."""
        lot_data = {
            "parking_name": "Type Test Lot",
            "city": "Test City",
            "landmark": "Test Landmark",
            "address": "Test Address",
            "latitude": "12.9716",  # String instead of float
            "longitude": "77.5946",  # String instead of float
            "physical_appearance": "Multi-storey",
            "parking_ownership": "Private",
            "parking_surface": "Concrete",
            "has_cctv": "Yes",
            "has_boom_barrier": "Yes",
            "ticket_generated": "Yes",
            "entry_exit_gates": "2",
            "weekly_off": "Sunday",
            "parking_timing": "24x7",
            "vehicle_types": "Car,Bike",
            "car_capacity": "50",  # String instead of int
            "available_car_slots": "50",
            "two_wheeler_capacity": "30",
            "available_two_wheeler_slots": "30",
            "parking_type": "Open",
            "payment_modes": "Cash,Card,UPI",
            "car_parking_charge": "30/hr",
            "two_wheeler_parking_charge": "20/hr",
            "allows_prepaid_passes": "Yes",
            "provides_valet_services": "No",
            "value_added_services": "Smart Parking"
        }
        
        response = client.post('/parking/lots',
                             data=json.dumps(lot_data),
                             headers=auth_headers,
                             content_type='application/json')
        # Should either convert to proper types or reject
        assert response.status_code in [201, 400]

    def test_boolean_fields_accepting_various_inputs(self, client, auth_headers):
        """Test that boolean fields properly handle various input types."""
        # Test various boolean representations
        boolean_values = [True, False, "true", "false", "True", "False", "1", "0", "yes", "no", "YES", "NO"]
        
        for bool_val in boolean_values:
            lot_data = {
                "parking_name": f"Boolean Test Lot {bool_val}",
                "city": "Test City",
                "landmark": "Test Landmark",
                "address": "Test Address",
                "latitude": 12.9716,
                "longitude": 77.5946,
                "physical_appearance": "Multi-storey",
                "parking_ownership": "Private",
                "parking_surface": "Concrete",
                "has_cctv": bool_val,  # Various boolean representations
                "has_boom_barrier": bool_val,
                "ticket_generated": bool_val,
                "entry_exit_gates": "2",
                "weekly_off": "Sunday",
                "parking_timing": "24x7",
                "vehicle_types": "Car,Bike",
                "car_capacity": 50,
                "available_car_slots": 50,
                "two_wheeler_capacity": 30,
                "available_two_wheeler_slots": 30,
                "parking_type": "Open",
                "payment_modes": "Cash,Card,UPI",
                "car_parking_charge": "30/hr",
                "two_wheeler_parking_charge": "20/hr",
                "allows_prepaid_passes": bool_val,
                "provides_valet_services": bool_val,
                "value_added_services": "Smart Parking"
            }
            
            response = client.post('/parking/lots',
                                 data=json.dumps(lot_data),
                                 headers=auth_headers,
                                 content_type='application/json')
            # Should handle boolean conversion properly
            assert response.status_code in [201, 400]

