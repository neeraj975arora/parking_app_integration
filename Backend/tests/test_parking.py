import json

def test_create_parking_lot(client, auth_headers):
    """
    GIVEN a Flask application and authenticated user
    WHEN a POST request is sent to '/parking/lots'
    THEN check that a '201' status code is returned and a new parking lot is created.
    """
    response = client.post('/parking/lots',
                           headers=auth_headers,
                           data=json.dumps(dict(
                               name='My Test Lot',
                               address='123 Pytest Ave',
                               city='Testville',
                               landmark='Near Test Landmark',
                               latitude=12.345,
                               longitude=67.890,
                               physical_appearance='Multi-storey',
                               parking_ownership='Private',
                               parking_surface='Concrete',
                               has_cctv='Yes',
                               has_boom_barrier='Yes',
                               ticket_generated='Yes',
                               entry_exit_gates='2',
                               weekly_off='Sunday',
                               parking_timing='24x7',
                               vehicle_types='Car,Bike',
                               car_capacity=50,
                               available_car_slots=50,
                               two_wheeler_capacity=100,
                               available_two_wheeler_slots=100,
                               parking_type='Open',
                               payment_modes='Cash,Card,UPI',
                               car_parking_charge='20/hr',
                               two_wheeler_parking_charge='10/hr',
                               allows_prepaid_passes='Yes',
                               provides_valet_services='No',
                               value_added_services='Car Wash'
                           )),
                           content_type='application/json')
    if response.status_code != 201:
        print('Error response:', response.data)
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['name'] == 'My Test Lot'
    assert data['address'] == '123 Pytest Ave'

def test_get_parking_lots(client, auth_headers):
    """
    GIVEN a Flask application and an existing parking lot
    WHEN a GET request is sent to '/parking/lots'
    THEN check that a '200' status code is returned and the list contains the parking lot.
    """
    response = client.get('/parking/lots', headers=auth_headers)
    assert response.status_code == 200
    data = json.loads(response.data)
    assert isinstance(data, list)
    assert len(data) > 0
    assert data[0]['name'] == 'My Test Lot'

def test_create_floor(client, auth_headers):
    """
    GIVEN a Flask application and an existing parking lot
    WHEN a POST request is sent to '/parking/lots/1/floors'
    THEN check that a '201' status code is returned and a new floor is created.
    """
    response = client.post('/parking/lots/1/floors',
                           headers=auth_headers,
                           data=json.dumps(dict(name='Floor 1')),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['name'] == 'Floor 1'

def test_create_row(client, auth_headers):
    """
    GIVEN a Flask application and an existing floor
    WHEN a POST request is sent to '/parking/floors/1/rows'
    THEN check that a '201' status code is returned and a new row is created.
    """
    response = client.post('/parking/floors/1/rows',
                           headers=auth_headers,
                           data=json.dumps(dict(name='Row A')),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['name'] == 'Row A'

def test_create_slot(client, auth_headers):
    """
    GIVEN a Flask application and an existing row
    WHEN a POST request is sent to '/parking/rows/1/slots'
    THEN check that a '201' status code is returned and a new slot is created.
    """
    response = client.post('/parking/rows/1/slots',
                           headers=auth_headers,
                           data=json.dumps(dict(name='A1')),
                           content_type='application/json')
    assert response.status_code == 201
    data = json.loads(response.data)
    assert data['name'] == 'A1'
    assert data['status'] == 0 # Default status 