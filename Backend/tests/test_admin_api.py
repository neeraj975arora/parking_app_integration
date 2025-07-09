import json
import pytest
import uuid

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

def test_admin_lot_assignment_flow(client):
    unique_id = str(uuid.uuid4())[:8]
    super_admin_email = f'superadmin_{unique_id}@example.com'
    admin_email = f'admin_{unique_id}@example.com'
    super_admin_phone = f'1111{unique_id[:6]}'
    admin_phone = f'2222{unique_id[:6]}'
    reg_resp = register_user(client, role='super_admin', email=super_admin_email, phone=super_admin_phone)
    print('Super admin registration:', reg_resp.status_code, reg_resp.data)
    assert reg_resp.status_code == 201
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    print('Admin registration:', reg_resp.status_code, reg_resp.data)
    assert reg_resp.status_code == 201
    # Login as super_admin
    resp = login_user(client, super_admin_email)
    print('Super admin login:', resp.status_code, resp.data)
    assert resp.status_code == 200
    super_admin_login_data = json.loads(resp.data)
    super_admin_token = super_admin_login_data['access_token']
    # Login as admin
    resp = login_user(client, admin_email)
    print('Admin login:', resp.status_code, resp.data)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    admin_id = admin_login_data['user_id']
    # Create a parking lot (direct DB insert for test)
    from app.models import db, ParkingLotDetails
    lot = ParkingLotDetails(
        name='Test Lot', city='Test City', landmark='Test Landmark', address='Test Address',
        latitude=0, longitude=0, physical_appearance='', parking_ownership='', parking_surface='',
        has_cctv='', has_boom_barrier='', ticket_generated='', entry_exit_gates='', weekly_off='',
        parking_timing='', vehicle_types='', car_capacity=1, available_car_slots=1,
        two_wheeler_capacity=1, available_two_wheeler_slots=1, parking_type='', payment_modes='',
        car_parking_charge='', two_wheeler_parking_charge='', allows_prepaid_passes='', provides_valet_services='', value_added_services='')
    db.session.add(lot)
    db.session.commit()
    lot_id = lot.id
    # Assign lot to admin (super_admin only)
    resp = client.post('/admin/assign_lot',
        data=json.dumps({'admin_id': admin_id, 'parking_lot_id': lot_id}),
        headers={'Authorization': f'Bearer {super_admin_token}'},
        content_type='application/json')
    print('Assign lot to admin:', resp.status_code, resp.data)
    assert resp.status_code == 201
    # Try assigning as admin (should fail)
    resp = client.post('/admin/assign_lot',
        data=json.dumps({'admin_id': admin_id, 'parking_lot_id': lot_id}),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 403
    # List lots for admin (admin can access)
    resp = client.get(f'/admin/admin_lots/{admin_id}', headers={'Authorization': f'Bearer {admin_token}'})
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert lot_id in data['parking_lot_ids']
    # Remove assignment (super_admin only)
    resp = client.delete('/admin/remove_assignment',
        data=json.dumps({'admin_id': admin_id, 'parking_lot_id': lot_id}),
        headers={'Authorization': f'Bearer {super_admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    # Try removing as admin (should fail)
    resp = client.delete('/admin/remove_assignment',
        data=json.dumps({'admin_id': admin_id, 'parking_lot_id': lot_id}),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 403
    # List admins for lot (admin can access)
    resp = client.get(f'/admin/lot_admins/{lot_id}', headers={'Authorization': f'Bearer {admin_token}'})
    assert resp.status_code == 200

def test_vehicle_checkin_flow(client):
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_checkin_{unique_id}@example.com'
    admin_phone = f'3333{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    # Create a parking lot, slot
    from app.models import db, ParkingLotDetails, Slot
    lot = ParkingLotDetails(
        name='Checkin Lot', city='Test City', landmark='Test Landmark', address='Test Address',
        latitude=0, longitude=0, physical_appearance='', parking_ownership='', parking_surface='',
        has_cctv='', has_boom_barrier='', ticket_generated='', entry_exit_gates='', weekly_off='',
        parking_timing='', vehicle_types='', car_capacity=1, available_car_slots=1,
        two_wheeler_capacity=1, available_two_wheeler_slots=1, parking_type='', payment_modes='',
        car_parking_charge='', two_wheeler_parking_charge='', allows_prepaid_passes='', provides_valet_services='', value_added_services='')
    db.session.add(lot)
    db.session.commit()
    lot_id = lot.id
    slot = Slot(
        name='A1', status=0, row_id=1, floor_id=1, parkinglot_id=lot_id
    )
    db.session.add(slot)
    db.session.commit()
    slot_id = slot.id
    # Happy path: check in vehicle
    payload = {
        'vehicle_reg_no': 'DL01AB1234',
        'slot_id': slot_id,
        'lot_id': lot_id,
        'vehicle_type': 'Car'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert 'session_id' in data
    # Try to check in again with same slot (should fail: slot occupied)
    payload2 = {
        'vehicle_reg_no': 'DL01AB5678',
        'slot_id': slot_id,
        'lot_id': lot_id,
        'vehicle_type': 'Car'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload2),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 409
    # Try to check in again with same vehicle (should fail: duplicate vehicle)
    slot2 = Slot(
        name='A2', status=0, row_id=1, floor_id=1, parkinglot_id=lot_id
    )
    db.session.add(slot2)
    db.session.commit()
    payload3 = {
        'vehicle_reg_no': 'DL01AB1234',
        'slot_id': slot2.id,
        'lot_id': lot_id,
        'vehicle_type': 'Car'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload3),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 409 

def test_vehicle_checkout_flow(client):
    import uuid
    from datetime import timedelta
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_checkout_{unique_id}@example.com'
    admin_phone = f'4444{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    # Create a parking lot, slot
    from app.models import db, ParkingLotDetails, Slot, ParkingSession, AdminParkingLot
    lot = ParkingLotDetails(
        name='Checkout Lot', city='Test City', landmark='Test Landmark', address='Test Address',
        latitude=0, longitude=0, physical_appearance='', parking_ownership='', parking_surface='',
        has_cctv='', has_boom_barrier='', ticket_generated='', entry_exit_gates='', weekly_off='',
        parking_timing='', vehicle_types='', car_capacity=1, available_car_slots=1,
        two_wheeler_capacity=1, available_two_wheeler_slots=1, parking_type='', payment_modes='',
        car_parking_charge='20/hr', two_wheeler_parking_charge='10/hr', allows_prepaid_passes='', provides_valet_services='', value_added_services='')
    db.session.add(lot)
    db.session.commit()
    lot_id = lot.id
    slot = Slot(
        name='B1', status=1, row_id=1, floor_id=1, parkinglot_id=lot_id, vehicle_reg_no='DL01AB9999'
    )
    db.session.add(slot)
    db.session.commit()
    slot_id = slot.id
    # Assign lot to admin
    assignment = AdminParkingLot(admin_id=admin_login_data['user_id'], parking_lot_id=lot_id)
    db.session.add(assignment)
    db.session.commit()
    # Create an active session for the vehicle
    from datetime import datetime
    ticket_id = str(uuid.uuid4())
    start_time = datetime.utcnow() - timedelta(hours=2, minutes=30)  # 2.5 hours ago
    session = ParkingSession(
        ticket_id=ticket_id,
        parkinglot_id=lot_id,
        slot_id=slot_id,
        vehicle_reg_no='DL01AB9999',
        start_time=start_time,
        vehicle_type='Car'
    )
    db.session.add(session)
    db.session.commit()
    # Happy path: check out vehicle
    payload = {'vehicle_reg_no': 'DL01AB9999'}
    resp = client.post('/admin/session/checkout',
        data=json.dumps(payload),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert 'amount_paid' in data
    assert 'duration_hours' in data
    assert 'checkout_time' in data
    assert data['amount_paid'] == 60.0  # 3 hours * 20/hr
    assert data['duration_hours'] == 3
    # Try to check out again (should fail: no active session)
    resp = client.post('/admin/session/checkout',
        data=json.dumps(payload),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 404
    # Try to check out with no session (different vehicle)
    payload2 = {'vehicle_reg_no': 'DL01AB0000'}
    resp = client.post('/admin/session/checkout',
        data=json.dumps(payload2),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 404 

def test_vehicle_type_billing_flow(client):
    import uuid
    from datetime import timedelta
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_type_{unique_id}@example.com'
    admin_phone = f'5555{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    from app.models import db, ParkingLotDetails, Slot, ParkingSession, AdminParkingLot
    lot = ParkingLotDetails(
        name='Type Lot', city='Test City', landmark='Test Landmark', address='Test Address',
        latitude=0, longitude=0, physical_appearance='', parking_ownership='', parking_surface='',
        has_cctv='', has_boom_barrier='', ticket_generated='', entry_exit_gates='', weekly_off='',
        parking_timing='', vehicle_types='', car_capacity=1, available_car_slots=1,
        two_wheeler_capacity=1, available_two_wheeler_slots=1, parking_type='', payment_modes='',
        car_parking_charge='20/hr', two_wheeler_parking_charge='10/hr', allows_prepaid_passes='', provides_valet_services='', value_added_services='')
    db.session.add(lot)
    db.session.commit()
    lot_id = lot.id
    # Assign lot to admin
    assignment = AdminParkingLot(admin_id=admin_login_data['user_id'], parking_lot_id=lot_id)
    db.session.add(assignment)
    db.session.commit()
    # Car check-in/check-out
    slot_car = Slot(
        name='C1', status=0, row_id=1, floor_id=1, parkinglot_id=lot_id
    )
    db.session.add(slot_car)
    db.session.commit()
    slot_car_id = slot_car.id
    payload_car = {
        'vehicle_reg_no': 'CAR123',
        'slot_id': slot_car_id,
        'lot_id': lot_id,
        'vehicle_type': 'Car'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload_car),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    # Fast-forward time for session
    session_car = ParkingSession.query.filter_by(vehicle_reg_no='CAR123', end_time=None).first()
    session_car.start_time -= timedelta(hours=1, minutes=30)  # 1.5 hours
    db.session.commit()
    # Car check-out
    resp = client.post('/admin/session/checkout',
        data=json.dumps({'vehicle_reg_no': 'CAR123'}),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data['amount_paid'] == 40.0  # 2 hours * 20/hr
    assert data['duration_hours'] == 2
    # Two-Wheeler check-in/check-out
    slot_bike = Slot(
        name='B1', status=0, row_id=1, floor_id=1, parkinglot_id=lot_id
    )
    db.session.add(slot_bike)
    db.session.commit()
    slot_bike_id = slot_bike.id
    payload_bike = {
        'vehicle_reg_no': 'BIKE123',
        'slot_id': slot_bike_id,
        'lot_id': lot_id,
        'vehicle_type': 'Two-Wheeler'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload_bike),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    session_bike = ParkingSession.query.filter_by(vehicle_reg_no='BIKE123', end_time=None).first()
    session_bike.start_time -= timedelta(hours=2, minutes=10)  # 2.17 hours
    db.session.commit()
    resp = client.post('/admin/session/checkout',
        data=json.dumps({'vehicle_reg_no': 'BIKE123'}),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 200
    data = json.loads(resp.data)
    assert data['amount_paid'] == 30.0  # 3 hours * 10/hr
    assert data['duration_hours'] == 3
    # Edge case: missing vehicle_type on check-in
    payload_missing_type = {
        'vehicle_reg_no': 'MISSINGTYPE',
        'slot_id': slot_bike_id,
        'lot_id': lot_id
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload_missing_type),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    assert resp.status_code == 400
    # Edge case: invalid vehicle_type
    payload_invalid_type = {
        'vehicle_reg_no': 'INVALIDTYPE',
        'slot_id': slot_bike_id,
        'lot_id': lot_id,
        'vehicle_type': 'Spaceship'
    }
    resp = client.post('/admin/session/checkin',
        data=json.dumps(payload_invalid_type),
        headers={'Authorization': f'Bearer {admin_token}'},
        content_type='application/json')
    # Accepts but will use two_wheeler rate (default else branch), can assert 200 or 409 if slot is occupied
    assert resp.status_code in (200, 409) 

def test_admin_closure_happy_path(client):
    import uuid
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_closure_{unique_id}@example.com'
    admin_phone = f'5555{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    # Simulate a checkout to increment today_collection
    from app.models import db, ParkingLotDetails, Slot, ParkingSession, AdminParkingLot
    lot = ParkingLotDetails(
        name='Closure Lot', city='Test City', landmark='Test Landmark', address='Test Address',
        latitude=0, longitude=0, physical_appearance='', parking_ownership='', parking_surface='',
        has_cctv='', has_boom_barrier='', ticket_generated='', entry_exit_gates='', weekly_off='',
        parking_timing='', vehicle_types='', car_capacity=1, available_car_slots=1,
        two_wheeler_capacity=1, available_two_wheeler_slots=1, parking_type='', payment_modes='',
        car_parking_charge='20/hr', two_wheeler_parking_charge='10/hr', allows_prepaid_passes='', provides_valet_services='', value_added_services='')
    db.session.add(lot)
    db.session.commit()
    lot_id = lot.id
    slot = Slot(
        name='C1', status=1, row_id=1, floor_id=1, parkinglot_id=lot_id, vehicle_reg_no='DL01AB0001'
    )
    db.session.add(slot)
    db.session.commit()
    # Assign lot to admin
    assignment = AdminParkingLot(admin_id=admin_login_data['user_id'], parking_lot_id=lot_id)
    db.session.add(assignment)
    db.session.commit()
    # Create a session and checkout
    session = ParkingSession(
        ticket_id=str(uuid.uuid4()),
        parkinglot_id=lot_id,
        slot_id=slot.id,
        vehicle_reg_no='DL01AB0001',
        start_time=None,
        end_time=None,
        vehicle_type='Car'
    )
    db.session.add(session)
    db.session.commit()
    # Checkout (simulate via API)
    payload = {'vehicle_reg_no': 'DL01AB0001'}
    resp = client.post('/admin/session/checkout', data=json.dumps(payload), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 200
    # POST closure (no today_collection in payload)
    payload = {"payment_made": 10.0}
    resp = client.post('/admin/closure', data=json.dumps(payload), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    data = json.loads(resp.data)
    assert set(data.keys()) == {"opening_balance", "today_collection", "payment_made", "closing_balance"}
    assert data['payment_made'] == 10.0
    assert data['today_collection'] > 0
    # GET closure
    resp = client.get('/admin/closure', headers={'Authorization': f'Bearer {admin_token}'})
    assert resp.status_code == 200
    entries = json.loads(resp.data)
    assert len(entries) >= 1
    assert any(e['today_collection'] > 0 for e in entries)


def test_admin_closure_duplicate_entry(client):
    import uuid
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_closure_dup_{unique_id}@example.com'
    admin_phone = f'6666{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    payload = {"payment_made": 5.0}
    resp = client.post('/admin/closure', data=json.dumps(payload), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    # Try duplicate for same day (should update, not error)
    payload2 = {"payment_made": 7.0}
    resp = client.post('/admin/closure', data=json.dumps(payload2), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    data = json.loads(resp.data)
    assert data['payment_made'] == 7.0

def test_admin_closure_missing_fields(client):
    import uuid
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_closure_missing_{unique_id}@example.com'
    admin_phone = f'7777{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    # No payment_made (should default to 0)
    payload = {}
    resp = client.post('/admin/closure', data=json.dumps(payload), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    data = json.loads(resp.data)
    assert set(data.keys()) == {"opening_balance", "today_collection", "payment_made", "closing_balance"}
    assert data['payment_made'] == 0.0

def test_admin_closure_rbac(client):
    import uuid
    unique_id = str(uuid.uuid4())[:8]
    user_email = f'user_closure_{unique_id}@example.com'
    user_phone = f'8888{unique_id[:6]}'
    reg_resp = register_user(client, role='user', email=user_email, phone=user_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, user_email)
    assert resp.status_code == 200
    user_login_data = json.loads(resp.data)
    user_token = user_login_data['access_token']
    # Try POST as user
    payload = {"today_collection": 10.0}
    resp = client.post('/admin/closure', data=json.dumps(payload), headers={'Authorization': f'Bearer {user_token}'}, content_type='application/json')
    assert resp.status_code == 403
    # Try GET as user
    resp = client.get('/admin/closure', headers={'Authorization': f'Bearer {user_token}'})
    assert resp.status_code == 403

def test_admin_closure_date_filter(client):
    import uuid
    from datetime import date, timedelta
    unique_id = str(uuid.uuid4())[:8]
    admin_email = f'admin_closure_date_{unique_id}@example.com'
    admin_phone = f'9999{unique_id[:6]}'
    reg_resp = register_user(client, role='admin', email=admin_email, phone=admin_phone)
    assert reg_resp.status_code == 201
    resp = login_user(client, admin_email)
    assert resp.status_code == 200
    admin_login_data = json.loads(resp.data)
    admin_token = admin_login_data['access_token']
    # Add two entries for different dates
    d1 = (date.today() - timedelta(days=1)).isoformat()
    d2 = date.today().isoformat()
    payload1 = {"today_collection": 10.0, "date": d1}
    payload2 = {"today_collection": 20.0, "date": d2}
    resp = client.post('/admin/closure', data=json.dumps(payload1), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    resp = client.post('/admin/closure', data=json.dumps(payload2), headers={'Authorization': f'Bearer {admin_token}'}, content_type='application/json')
    assert resp.status_code == 201
    # Filter by start_date
    resp = client.get(f'/admin/closure?start_date={d2}', headers={'Authorization': f'Bearer {admin_token}'})
    assert resp.status_code == 200
    entries = json.loads(resp.data)
    assert all(e['date'] >= d2 for e in entries)
    # Filter by end_date
    resp = client.get(f'/admin/closure?end_date={d1}', headers={'Authorization': f'Bearer {admin_token}'})
    assert resp.status_code == 200
    entries = json.loads(resp.data)
    assert all(e['date'] <= d1 for e in entries) 