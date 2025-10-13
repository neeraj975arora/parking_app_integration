"""
Test Configuration and Utilities
===============================

This module provides configuration and utilities for testing the Smart Parking Backend.
It includes test data factories, database fixtures, and test environment setup.
"""
import pytest
import os
import json
import uuid
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional
from app import create_app, db
from app.models import User, ParkingLotDetails, Floor, Row, Slot, ParkingSession, AdminParkingLot


class TestDataFactory:
    """Factory class for creating test data."""
    
    @staticmethod
    def create_user_data(role: str = 'user', **kwargs) -> Dict[str, Any]:
        """Create user data for testing."""
        unique_id = str(uuid.uuid4())[:8]
        base_data = {
            'user_name': f'test_{role}_{unique_id}',
            'user_email': f'{role}_{unique_id}@example.com',
            'user_password': 'testpassword',
            'user_phone_no': f'1000000{unique_id[:6]}',
            'user_address': 'Test Address',
        }
        
        if role == 'super_admin':
            base_data.update({
                'role': 'super_admin',
                'super_admin_secret': 'SUPER_SECRET_SUPER_ADMIN_KEY'
            })
        
        base_data.update(kwargs)
        return base_data
    
    @staticmethod
    def create_parking_lot_data(**kwargs) -> Dict[str, Any]:
        """Create parking lot data for testing."""
        unique_id = str(uuid.uuid4())[:8]
        base_data = {
            'name': f'Test Lot {unique_id}',
            'address': f'123 Test St {unique_id}',
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
        base_data.update(kwargs)
        return base_data
    
    @staticmethod
    def create_session_data(**kwargs) -> Dict[str, Any]:
        """Create parking session data for testing."""
        base_data = {
            'vehicle_reg_no': f'DL{str(uuid.uuid4())[:6].upper()}',
            'vehicle_type': 'Car',
            'start_time': datetime.utcnow(),
            'end_time': None,
            'amount_paid': 0.0
        }
        base_data.update(kwargs)
        return base_data


class TestEnvironment:
    """Test environment configuration and utilities."""
    
    @staticmethod
    def setup_test_database(app):
        """Setup test database with initial data."""
        with app.app_context():
            db.create_all()
            
            # Create test super admin
            super_admin = User(
                user_name='test_super_admin',
                user_email='superadmin@test.com',
                user_phone_no='1111111111',
                user_address='Test HQ',
                role='super_admin'
            )
            super_admin.set_password('testpassword')
            db.session.add(super_admin)
            db.session.commit()
    
    @staticmethod
    def cleanup_test_database(app):
        """Cleanup test database."""
        with app.app_context():
            db.drop_all()


class TestAPIClient:
    """Enhanced API client for testing."""
    
    def __init__(self, client):
        self.client = client
        self.auth_headers = {}
        self.base_url = ''
    
    def authenticate_user(self, email: str, password: str, role: str = 'user') -> Dict[str, str]:
        """Authenticate a user and return auth headers."""
        login_data = {
            'user_email': email,
            'user_password': password,
            'role': role
        }
        response = self.client.post('/auth/login',
                                  data=json.dumps(login_data),
                                  content_type='application/json')
        
        if response.status_code != 200:
            raise Exception(f"Authentication failed: {response.data}")
        
        response_data = json.loads(response.data)
        access_token = response_data['access_token']
        self.auth_headers = {'Authorization': f'Bearer {access_token}'}
        return self.auth_headers
    
    def create_parking_lot(self, lot_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a parking lot and return the response data."""
        response = self.client.post('/parking/lots',
                                   headers=self.auth_headers,
                                   data=json.dumps(lot_data),
                                   content_type='application/json')
        
        if response.status_code != 201:
            raise Exception(f"Failed to create parking lot: {response.data}")
        
        return json.loads(response.data)
    
    def create_parking_structure(self, lot_id: int, floors: int = 1, rows_per_floor: int = 1, slots_per_row: int = 1) -> Dict[str, Any]:
        """Create a complete parking structure."""
        structure = {
            'lot_id': lot_id,
            'floors': [],
            'total_slots': 0
        }
        
        for floor_num in range(1, floors + 1):
            floor_data = {'name': f'Floor {floor_num}'}
            response = self.client.post(f'/parking/lots/{lot_id}/floors',
                                      headers=self.auth_headers,
                                      data=json.dumps(floor_data),
                                      content_type='application/json')
            
            if response.status_code != 201:
                raise Exception(f"Failed to create floor: {response.data}")
            
            floor_response = json.loads(response.data)
            floor_id = floor_response['id']
            structure['floors'].append({
                'id': floor_id,
                'name': f'Floor {floor_num}',
                'rows': []
            })
            
            for row_num in range(1, rows_per_floor + 1):
                row_data = {'name': f'Row {floor_num}{row_num}'}
                response = self.client.post(f'/parking/floors/{floor_id}/rows',
                                          headers=self.auth_headers,
                                          data=json.dumps(row_data),
                                          content_type='application/json')
                
                if response.status_code != 201:
                    raise Exception(f"Failed to create row: {response.data}")
                
                row_response = json.loads(response.data)
                row_id = row_response['id']
                structure['floors'][-1]['rows'].append({
                    'id': row_id,
                    'name': f'Row {floor_num}{row_num}',
                    'slots': []
                })
                
                for slot_num in range(1, slots_per_row + 1):
                    slot_data = {'name': f'{floor_num}{row_num}{slot_num}'}
                    response = self.client.post(f'/parking/rows/{row_id}/slots',
                                              headers=self.auth_headers,
                                              data=json.dumps(slot_data),
                                              content_type='application/json')
                    
                    if response.status_code != 201:
                        raise Exception(f"Failed to create slot: {response.data}")
                    
                    slot_response = json.loads(response.data)
                    structure['floors'][-1]['rows'][-1]['slots'].append({
                        'id': slot_response['id'],
                        'name': f'{floor_num}{row_num}{slot_num}'
                    })
                    structure['total_slots'] += 1
        
        return structure


class TestAssertions:
    """Custom assertions for testing."""
    
    @staticmethod
    def assert_successful_response(response, expected_status: int = 200):
        """Assert that a response is successful."""
        assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.data}"
    
    @staticmethod
    def assert_error_response(response, expected_status: int):
        """Assert that a response is an error."""
        assert response.status_code == expected_status, f"Expected error {expected_status}, got {response.status_code}: {response.data}"
    
    @staticmethod
    def assert_json_response(response):
        """Assert that a response contains valid JSON."""
        try:
            return json.loads(response.data)
        except json.JSONDecodeError:
            assert False, f"Response is not valid JSON: {response.data}"
    
    @staticmethod
    def assert_parking_lot_structure(lot_data: Dict[str, Any], expected_floors: int, expected_rows_per_floor: int, expected_slots_per_row: int):
        """Assert that a parking lot has the expected structure."""
        assert len(lot_data['floors']) == expected_floors, f"Expected {expected_floors} floors, got {len(lot_data['floors'])}"
        
        total_slots = 0
        for floor in lot_data['floors']:
            assert len(floor['rows']) == expected_rows_per_floor, f"Expected {expected_rows_per_floor} rows per floor, got {len(floor['rows'])}"
            for row in floor['rows']:
                assert len(row['slots']) == expected_slots_per_row, f"Expected {expected_slots_per_row} slots per row, got {len(row['slots'])}"
                total_slots += len(row['slots'])
        
        expected_total_slots = expected_floors * expected_rows_per_floor * expected_slots_per_row
        assert total_slots == expected_total_slots, f"Expected {expected_total_slots} total slots, got {total_slots}"


# Test markers for different test categories
INTEGRATION_TEST = pytest.mark.integration
UNIT_TEST = pytest.mark.unit
SLOW_TEST = pytest.mark.slow
PERFORMANCE_TEST = pytest.mark.performance
SECURITY_TEST = pytest.mark.security
API_TEST = pytest.mark.api
DATABASE_TEST = pytest.mark.database
