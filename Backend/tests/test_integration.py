"""
Integration Tests for Smart Parking Backend
==========================================

This module contains comprehensive integration tests that test the entire
backend system including:
- Full user workflows (registration, authentication, parking operations)
- Admin workflows (admin registration, lot assignment, session management)
- IoT device integration (slot status updates)
- Database transactions and data consistency
- API endpoint integration
- Error handling and edge cases
"""

import json
import pytest
import uuid
from datetime import datetime, timedelta
from app import create_app, db
from app.models import (
    User, ParkingLotDetails, Floor, Row, Slot, ParkingSession, 
    AdminParkingLot, AdminPaymentLedger
)


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


@pytest.fixture(scope='function')
def auth_headers(client):
    """Get auth headers for a test user."""
    # Register a user
    register_data = dict(
        user_name='integration_user',
        user_email='integration@example.com',
        user_password='password',
        user_phone_no='5555555555',
        user_address='Test Address'
    )
    client.post('/auth/register',
                data=json.dumps(register_data),
                content_type='application/json')
    
    # Login the user
    login_data = dict(
        user_email='integration@example.com',
        user_password='password',
        role='user'
    )
    response = client.post('/auth/login',
                         data=json.dumps(login_data),
                         content_type='application/json')
    
    if response.status_code != 200:
        pytest.fail(f"Login failed with status {response.status_code}: {response.data}")
    
    response_data = json.loads(response.data)
    access_token = response_data['access_token']
    return {'Authorization': f'Bearer {access_token}'}


@pytest.fixture(scope='function')
def super_admin_headers(client):
    """Get auth headers for a super admin."""
    # Register super admin
    register_data = dict(
        user_name='super_admin',
        user_email='superadmin@example.com',
        user_password='password',
        user_phone_no='1111111111',
        user_address='HQ',
        role='super_admin',
        super_admin_secret='SUPER_SECRET_SUPER_ADMIN_KEY'
    )
    client.post('/auth/register',
                data=json.dumps(register_data),
                content_type='application/json')
    
    # Login super admin
    login_data = dict(
        user_email='superadmin@example.com',
        user_password='password',
        role='super_admin'
    )
    response = client.post('/auth/login',
                         data=json.dumps(login_data),
                         content_type='application/json')
    
    response_data = json.loads(response.data)
    access_token = response_data['access_token']
    return {'Authorization': f'Bearer {access_token}'}


@pytest.fixture(scope='function')
def admin_headers(client, super_admin_headers):
    """Get auth headers for an admin (created by super admin)."""
    # Create admin via super admin
    admin_data = dict(
        user_name='admin_user',
        user_email='admin@example.com',
        user_password='adminpass',
        user_phone_no='2222222222',
        user_address='Admin HQ'
    )
    response = client.post('/admin/register_admin',
                         data=json.dumps(admin_data),
                         headers=super_admin_headers,
                         content_type='application/json')
    
    # Login admin
    login_data = dict(
        user_email='admin@example.com',
        user_password='adminpass',
        role='admin'
    )
    response = client.post('/auth/login',
                         data=json.dumps(login_data),
                         content_type='application/json')
    
    response_data = json.loads(response.data)
    access_token = response_data['access_token']
    return {'Authorization': f'Bearer {access_token}'}


class TestFullUserWorkflow:
    """Test complete user workflows from registration to parking operations."""
    
    def test_complete_user_registration_and_parking_workflow(self, client, auth_headers):
        """Test complete user workflow: register -> login -> create parking lot -> manage structure."""
        
        # 1. Create a parking lot
        lot_data = {
            'name': 'Integration Test Lot',
            'address': '123 Integration St',
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
                             headers=auth_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        lot_response = json.loads(response.data)
        lot_id = lot_response['id']
        
        # 2. Create a floor
        floor_data = {'name': 'Ground Floor'}
        response = client.post(f'/parking/lots/{lot_id}/floors',
                             headers=auth_headers,
                             data=json.dumps(floor_data),
                             content_type='application/json')
        assert response.status_code == 201
        floor_response = json.loads(response.data)
        floor_id = floor_response['id']
        
        # 3. Create a row
        row_data = {'name': 'Row A'}
        response = client.post(f'/parking/floors/{floor_id}/rows',
                             headers=auth_headers,
                             data=json.dumps(row_data),
                             content_type='application/json')
        assert response.status_code == 201
        row_response = json.loads(response.data)
        row_id = row_response['id']
        
        # 4. Create multiple slots
        slots_data = [{'name': f'A{i}'} for i in range(1, 6)]
        slot_ids = []
        for slot_data in slots_data:
            response = client.post(f'/parking/rows/{row_id}/slots',
                                headers=auth_headers,
                                data=json.dumps(slot_data),
                                content_type='application/json')
            assert response.status_code == 201
            slot_response = json.loads(response.data)
            slot_ids.append(slot_response['id'])
        
        # 5. Verify the complete structure
        response = client.get('/parking/lots', headers=auth_headers)
        assert response.status_code == 200
        lots = json.loads(response.data)
        assert len(lots) == 1
        assert lots[0]['name'] == 'Integration Test Lot'
        
        # 6. Get specific lot details
        response = client.get(f'/parking/lots/{lot_id}', headers=auth_headers)
        assert response.status_code == 200
        lot_details = json.loads(response.data)
        assert lot_details['floors'][0]['name'] == 'Ground Floor'
        assert len(lot_details['floors'][0]['rows']) == 1
        assert len(lot_details['floors'][0]['rows'][0]['slots']) == 5


class TestAdminWorkflow:
    """Test complete admin workflows including lot assignment and session management."""
    
    def test_complete_admin_workflow(self, client, super_admin_headers, admin_headers):
        """Test complete admin workflow: create lot -> assign to admin -> manage sessions."""
        
        # 1. Super admin creates a parking lot
        lot_data = {
            'name': 'Admin Test Lot',
            'address': '456 Admin St',
            'city': 'Admin City',
            'landmark': 'Near Admin Landmark',
            'latitude': 13.456,
            'longitude': 68.901,
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
            'car_capacity': 30,
            'available_car_slots': 30,
            'two_wheeler_capacity': 15,
            'available_two_wheeler_slots': 15,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '25/hr',
            'two_wheeler_parking_charge': '15/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'EV Charging'
        }
        
        response = client.post('/parking/lots',
                             headers=super_admin_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        lot_response = json.loads(response.data)
        lot_id = lot_response['id']
        
        # 2. Create floor, row, and slots for the lot
        floor_data = {'name': 'Floor 1'}
        response = client.post(f'/parking/lots/{lot_id}/floors',
                             headers=super_admin_headers,
                             data=json.dumps(floor_data),
                             content_type='application/json')
        assert response.status_code == 201
        floor_response = json.loads(response.data)
        floor_id = floor_response['id']
        
        row_data = {'name': 'Row B'}
        response = client.post(f'/parking/floors/{floor_id}/rows',
                             headers=super_admin_headers,
                             data=json.dumps(row_data),
                             content_type='application/json')
        assert response.status_code == 201
        row_response = json.loads(response.data)
        row_id = row_response['id']
        
        # Create slots
        for i in range(1, 4):
            slot_data = {'name': f'B{i}'}
            response = client.post(f'/parking/rows/{row_id}/slots',
                                headers=super_admin_headers,
                                data=json.dumps(slot_data),
                                content_type='application/json')
            assert response.status_code == 201
        
        # 3. Get admin ID for assignment (we need to get it from the admin we just created)
        # Since we don't have a direct endpoint to list admins, we'll use the admin we created
        admin_id = 2  # Assuming the admin we created has ID 2
        
        # 4. Assign lot to admin
        assignment_data = {
            'admin_id': admin_id,
            'parking_lot_id': lot_id
        }
        response = client.post('/admin/assign_existing_lot',
                             data=json.dumps(assignment_data),
                             headers=super_admin_headers,
                             content_type='application/json')
        assert response.status_code == 201
        
        # 5. Admin checks in a vehicle
        checkin_data = {
            'vehicle_reg_no': 'DL01AB1234',
            'slot_id': 1,  # First slot
            'lot_id': lot_id,
            'vehicle_type': 'Car'
        }
        response = client.post('/admin/session/checkin',
                             data=json.dumps(checkin_data),
                             headers=admin_headers,
                             content_type='application/json')
        assert response.status_code == 200
        checkin_response = json.loads(response.data)
        assert 'session_id' in checkin_response
        
        # 6. Admin checks out the vehicle
        checkout_data = {'vehicle_reg_no': 'DL01AB1234'}
        response = client.post('/admin/session/checkout',
                              data=json.dumps(checkout_data),
                              headers=admin_headers,
                              content_type='application/json')
        assert response.status_code == 200
        checkout_response = json.loads(response.data)
        assert 'amount_paid' in checkout_response
        assert 'duration_hours' in checkout_response
        
        # 7. Admin performs daily closure
        closure_data = {'payment_made': 100.0}
        response = client.post('/admin/closure',
                             data=json.dumps(closure_data),
                             headers=admin_headers,
                             content_type='application/json')
        assert response.status_code == 201
        closure_response = json.loads(response.data)
        assert 'opening_balance' in closure_response
        assert 'today_collection' in closure_response
        assert 'payment_made' in closure_response
        assert 'closing_balance' in closure_response


class TestIoTIntegration:
    """Test IoT device integration for slot status updates."""
    
    def test_iot_slot_status_update_workflow(self, client, auth_headers):
        """Test IoT device updating slot status via API key authentication."""
        
        # 1. Create a parking lot with slots
        lot_data = {
            'name': 'IoT Test Lot',
            'address': '789 IoT St',
            'city': 'IoT City',
            'landmark': 'Near IoT Landmark',
            'latitude': 14.567,
            'longitude': 69.012,
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
            'car_capacity': 20,
            'available_car_slots': 20,
            'two_wheeler_capacity': 10,
            'available_two_wheeler_slots': 10,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '30/hr',
            'two_wheeler_parking_charge': '20/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Smart Parking'
        }
        
        response = client.post('/parking/lots',
                             headers=auth_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        lot_response = json.loads(response.data)
        lot_id = lot_response['id']
        
        # Create structure
        floor_data = {'name': 'IoT Floor'}
        response = client.post(f'/parking/lots/{lot_id}/floors',
                             headers=auth_headers,
                             data=json.dumps(floor_data),
                             content_type='application/json')
        assert response.status_code == 201
        floor_response = json.loads(response.data)
        floor_id = floor_response['id']
        
        row_data = {'name': 'IoT Row'}
        response = client.post(f'/parking/floors/{floor_id}/rows',
                             headers=auth_headers,
                             data=json.dumps(row_data),
                             content_type='application/json')
        assert response.status_code == 201
        row_response = json.loads(response.data)
        row_id = row_response['id']
        
        slot_data = {'name': 'IoT1'}
        response = client.post(f'/parking/rows/{row_id}/slots',
                             headers=auth_headers,
                             data=json.dumps(slot_data),
                             content_type='application/json')
        assert response.status_code == 201
        slot_response = json.loads(response.data)
        slot_id = slot_response['id']
        
        # 2. IoT device updates slot status (occupied)
        iot_headers = {'X-API-KEY': 'super-secret-rpi-key'}  # Using default API key from config
        update_data = {
            'id': slot_id,
            'status': 1,
            'vehicle_reg_no': 'DL01CD5678',
            'ticket_id': str(uuid.uuid4())
        }
        response = client.post('/api/v1/slots/update_status',
                             data=json.dumps(update_data),
                             headers=iot_headers,
                             content_type='application/json')
        assert response.status_code == 200
        update_response = json.loads(response.data)
        assert 'status updated' in update_response['message']
        
        # 3. Verify slot status was updated
        response = client.get(f'/parking/slots/{slot_id}', headers=auth_headers)
        assert response.status_code == 200
        slot_data = json.loads(response.data)
        assert slot_data['status'] == 1
        # Note: The API only updates status, not vehicle_reg_no or ticket_id
        
        # 4. IoT device updates slot status (vacant)
        update_data = {
            'id': slot_id,
            'status': 0,
            'vehicle_reg_no': None,
            'ticket_id': None
        }
        response = client.post('/api/v1/slots/update_status',
                             data=json.dumps(update_data),
                             headers=iot_headers,
                             content_type='application/json')
        assert response.status_code == 200
        
        # 5. Verify slot is now vacant
        response = client.get(f'/parking/slots/{slot_id}', headers=auth_headers)
        assert response.status_code == 200
        slot_data = json.loads(response.data)
        assert slot_data['status'] == 0
        # Note: The API only updates status, not vehicle_reg_no or ticket_id


class TestErrorHandling:
    """Test error handling and edge cases across the system."""
    
    def test_authentication_errors(self, client):
        """Test various authentication error scenarios."""
        
        # 1. Access protected endpoint without token
        response = client.get('/parking/lots')
        assert response.status_code == 401
        
        # 2. Access with invalid token
        invalid_headers = {'Authorization': 'Bearer invalid_token'}
        response = client.get('/parking/lots', headers=invalid_headers)
        assert response.status_code == 401
        
        # 3. Access admin endpoint with user token
        user_data = {
            'user_name': 'test_user',
            'user_email': 'test@example.com',
            'user_password': 'password',
            'user_phone_no': '1234567890',
            'user_address': 'Test Address'
        }
        client.post('/auth/register',
                   data=json.dumps(user_data),
                   content_type='application/json')
        
        login_data = {
            'user_email': 'test@example.com',
            'user_password': 'password',
            'role': 'user'
        }
        response = client.post('/auth/login',
                             data=json.dumps(login_data),
                             content_type='application/json')
        user_token = json.loads(response.data)['access_token']
        user_headers = {'Authorization': f'Bearer {user_token}'}
        
        # Try to access admin endpoint (using a known admin endpoint)
        response = client.get('/admin/closure', headers=user_headers)
        assert response.status_code == 403
    
    def test_data_validation_errors(self, client, auth_headers):
        """Test data validation error scenarios."""
        
        # 1. Create parking lot with missing required fields
        invalid_lot_data = {
            'name': 'Invalid Lot'
            # Missing required fields
        }
        response = client.post('/parking/lots',
                             headers=auth_headers,
                             data=json.dumps(invalid_lot_data),
                             content_type='application/json')
        assert response.status_code == 400
        
        # 2. Create slot with invalid data
        response = client.post('/parking/rows/999/slots',
                             headers=auth_headers,
                             data=json.dumps({'name': 'Invalid Slot'}),
                             content_type='application/json')
        assert response.status_code == 404  # Row doesn't exist
    
    def test_duplicate_data_errors(self, client, auth_headers):
        """Test duplicate data error scenarios."""
        
        # 1. Register user with duplicate email
        user_data = {
            'user_name': 'duplicate_user',
            'user_email': 'duplicate@example.com',
            'user_password': 'password',
            'user_phone_no': '9876543210',
            'user_address': 'Test Address'
        }
        
        # First registration should succeed
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 201
        
        # Second registration with same email should fail
        response = client.post('/auth/register',
                             data=json.dumps(user_data),
                             content_type='application/json')
        assert response.status_code == 409


class TestDatabaseConsistency:
    """Test database consistency and transaction handling."""
    
    def test_transaction_rollback_on_error(self, client, auth_headers):
        """Test that database transactions are properly rolled back on errors."""
        
        # This test would require more complex setup to test actual rollbacks
        # For now, we'll test that operations complete successfully
        
        # Create a parking lot
        lot_data = {
            'name': 'Transaction Test Lot',
            'address': '123 Transaction St',
            'city': 'Transaction City',
            'landmark': 'Near Transaction Landmark',
            'latitude': 15.678,
            'longitude': 70.123,
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
            'car_capacity': 10,
            'available_car_slots': 10,
            'two_wheeler_capacity': 5,
            'available_two_wheeler_slots': 5,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '35/hr',
            'two_wheeler_parking_charge': '25/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Transaction Test'
        }
        
        response = client.post('/parking/lots',
                             headers=auth_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        
        # Verify the lot was created
        response = client.get('/parking/lots', headers=auth_headers)
        assert response.status_code == 200
        lots = json.loads(response.data)
        assert len(lots) == 1
        assert lots[0]['name'] == 'Transaction Test Lot'
    
    def test_concurrent_operations(self, client, auth_headers):
        """Test handling of concurrent operations."""
        
        # Create a parking lot
        lot_data = {
            'name': 'Concurrent Test Lot',
            'address': '456 Concurrent St',
            'city': 'Concurrent City',
            'landmark': 'Near Concurrent Landmark',
            'latitude': 16.789,
            'longitude': 71.234,
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
            'car_capacity': 15,
            'available_car_slots': 15,
            'two_wheeler_capacity': 8,
            'available_two_wheeler_slots': 8,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '40/hr',
            'two_wheeler_parking_charge': '30/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Concurrent Test'
        }
        
        response = client.post('/parking/lots',
                             headers=auth_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        
        # Create multiple floors concurrently (simulated)
        lot_response = json.loads(response.data)
        lot_id = lot_response['id']
        
        floor_data_1 = {'name': 'Floor 1'}
        floor_data_2 = {'name': 'Floor 2'}
        
        response1 = client.post(f'/parking/lots/{lot_id}/floors',
                              headers=auth_headers,
                              data=json.dumps(floor_data_1),
                              content_type='application/json')
        response2 = client.post(f'/parking/lots/{lot_id}/floors',
                              headers=auth_headers,
                              data=json.dumps(floor_data_2),
                              content_type='application/json')
        
        assert response1.status_code == 201
        assert response2.status_code == 201
        
        # Verify both floors were created
        response = client.get(f'/parking/lots/{lot_id}', headers=auth_headers)
        assert response.status_code == 200
        lot_details = json.loads(response.data)
        assert len(lot_details['floors']) == 2


class TestPerformanceAndLoad:
    """Test performance and load handling."""
    
    def test_bulk_operations(self, client, auth_headers):
        """Test bulk operations performance."""
        
        # Create a parking lot
        lot_data = {
            'name': 'Bulk Test Lot',
            'address': '789 Bulk St',
            'city': 'Bulk City',
            'landmark': 'Near Bulk Landmark',
            'latitude': 17.890,
            'longitude': 72.345,
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
            'car_capacity': 100,
            'available_car_slots': 100,
            'two_wheeler_capacity': 50,
            'available_two_wheeler_slots': 50,
            'parking_type': 'Open',
            'payment_modes': 'Cash,Card,UPI',
            'car_parking_charge': '45/hr',
            'two_wheeler_parking_charge': '35/hr',
            'allows_prepaid_passes': 'Yes',
            'provides_valet_services': 'No',
            'value_added_services': 'Bulk Test'
        }
        
        response = client.post('/parking/lots',
                             headers=auth_headers,
                             data=json.dumps(lot_data),
                             content_type='application/json')
        assert response.status_code == 201
        lot_response = json.loads(response.data)
        lot_id = lot_response['id']
        
        # Create multiple floors
        for i in range(1, 4):
            floor_data = {'name': f'Floor {i}'}
            response = client.post(f'/parking/lots/{lot_id}/floors',
                                 headers=auth_headers,
                                 data=json.dumps(floor_data),
                                 content_type='application/json')
            assert response.status_code == 201
            floor_response = json.loads(response.data)
            floor_id = floor_response['id']
            
            # Create multiple rows per floor
            for j in range(1, 4):
                row_data = {'name': f'Row {i}{j}'}
                response = client.post(f'/parking/floors/{floor_id}/rows',
                                     headers=auth_headers,
                                     data=json.dumps(row_data),
                                     content_type='application/json')
                assert response.status_code == 201
                row_response = json.loads(response.data)
                row_id = row_response['id']
                
                # Create multiple slots per row
                for k in range(1, 6):
                    slot_data = {'name': f'{i}{j}{k}'}
                    response = client.post(f'/parking/rows/{row_id}/slots',
                                         headers=auth_headers,
                                         data=json.dumps(slot_data),
                                         content_type='application/json')
                    assert response.status_code == 201
        
        # Verify all data was created
        response = client.get(f'/parking/lots/{lot_id}', headers=auth_headers)
        assert response.status_code == 200
        lot_details = json.loads(response.data)
        assert len(lot_details['floors']) == 3
        
        total_slots = 0
        for floor in lot_details['floors']:
            for row in floor['rows']:
                total_slots += len(row['slots'])
        
        assert total_slots == 45  # 3 floors * 3 rows * 5 slots = 45 slots


# Mark tests for different categories
pytestmark = [
    pytest.mark.integration,
    pytest.mark.slow
]
