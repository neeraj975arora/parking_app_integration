import requests
import json
import sys

BASE_URL = "http://localhost:5000"
API_KEY = "super-secret-rpi-key"  # Same as in your config.py

def register_user():
    print("--- Registering User ---")
    url = f"{BASE_URL}/auth/register"
    headers = {"Content-Type": "application/json"}
    data = {
        "user_name": "testuser",
        "user_email": "test@example.com",
        "user_password": "password",
        "user_phone_no": "1234567890"
    }
    try:
        response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
        print(f"Status Code: {response.status_code}")
        if response.status_code in [201, 409]:  # 409 means user already exists
            print("User registered successfully or already exists.")
        else:
            print(f"Response JSON: {response.json()}")
            sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during registration: {e}")
        sys.exit(1)

def login_user():
    print("\n--- Logging In User ---")
    url = f"{BASE_URL}/auth/login"
    headers = {"Content-Type": "application/json"}
    data = {
        "user_email": "test@example.com",
        "user_password": "password"
    }
    try:
        response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
        print(f"Status Code: {response.status_code}")
        response_data = response.json()
        print(f"Response JSON: {response_data}")
        if 'access_token' in response_data:
            print("Login successful.")
            return response_data['access_token']
        else:
            print("Login failed.")
            sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"An error occurred during login: {e}")
        sys.exit(1)

def create_parking_lot(token):
    print("\n--- Creating Parking Lot ---")
    url = f"{BASE_URL}/parking/lots"
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    data = {
        "name": "Test Lot",
        "address": "123 Test St",
        "city": "Test City",
        "landmark": "Near Test Landmark",
        "latitude": 12.345,
        "longitude": 67.890,
        "physical_appearance": "Multi-storey",
        "parking_ownership": "Private",
        "parking_surface": "Concrete",
        "has_cctv": "Yes",
        "has_boom_barrier": "Yes",
        "ticket_generated": "Yes",
        "entry_exit_gates": "2",
        "weekly_off": "Sunday",
        "parking_timing": "8am-10pm",
        "vehicle_types": "Car,Bike",
        "car_capacity": 50,
        "available_car_slots": 50,
        "two_wheeler_capacity": 20,
        "available_two_wheeler_slots": 20,
        "parking_type": "Open",
        "payment_modes": "Cash,Card",
        "car_parking_charge": "20/hr",
        "two_wheeler_parking_charge": "10/hr",
        "allows_prepaid_passes": "No",
        "provides_valet_services": "No",
        "value_added_services": "EV Charging"
    }
    response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
    print(f"Status Code: {response.status_code}")
    response_data = response.json()
    print(f"Response JSON: {response_data}")
    return response_data['id']

def create_floor(token, lot_id):
    print("\n--- Creating Floor ---")
    url = f"{BASE_URL}/parking/lots/{lot_id}/floors"
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    data = {"name": "G1", "parkinglot_id": lot_id}
    response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
    print(f"Status Code: {response.status_code}")
    response_data = response.json()
    print(f"Response JSON: {response_data}")
    return response_data['id']

def create_row(token, lot_id, floor_id):
    print("\n--- Creating Row ---")
    url = f"{BASE_URL}/parking/floors/{floor_id}/rows"
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    data = {"name": "A"}
    response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
    print(f"Status Code: {response.status_code}")
    response_data = response.json()
    print(f"Response JSON: {response_data}")
    return response_data['id']

def create_slot(token, lot_id, floor_id, row_id):
    print("\n--- Creating Slot ---")
    url = f"{BASE_URL}/parking/rows/{row_id}/slots"
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {token}"}
    data = {"name": "A1", "status": 0}
    response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
    print(f"Status Code: {response.status_code}")
    response_data = response.json()
    print(f"Response JSON: {response_data}")
    return response_data['id']

def update_slot_status(slot_id):
    print("\n--- Updating Slot Status (RPi) ---")
    url = f"{BASE_URL}/api/v1/slots/update_status"
    headers = {"Content-Type": "application/json", "X-API-KEY": API_KEY}
    data = {"id": slot_id, "status": 1} # 1 = occupied
    response = requests.post(url, headers=headers, data=json.dumps(data), timeout=5)
    print(f"Status Code: {response.status_code}")
    print(f"Response JSON: {response.json()}")

def verify_slot_status(token, lot_id, slot_id):
    print("\n--- Verifying Slot Status (Client) ---")
    url = f"{BASE_URL}/parking/lots/{lot_id}"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers, timeout=5)
    print(f"Status Code: {response.status_code}")
    lot_details = response.json()
    
    # Traverse the nested structure to find the slot
    for floor in lot_details.get('floors', []):
        for row in floor.get('rows', []):
            for slot in row.get('slots', []):
                if slot.get('id') == slot_id:
                    print(f"Found Slot {slot_id} with status: {slot.get('status')}")
                    if slot.get('status') == 1:
                        print("SUCCESS: Slot status was updated correctly!")
                    else:
                        print("FAILURE: Slot status was not updated.")
                    return

    print(f"FAILURE: Could not find Slot {slot_id} in lot details.")

def get_lot_stats(token, lot_id):
    print("\n--- Getting Parking Lot Stats ---")
    url = f"{BASE_URL}/parking/lots/{lot_id}/stats"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url, headers=headers, timeout=5)
    print(f"Status Code: {response.status_code}")
    stats = response.json()
    print(f"Response JSON: {stats}")
    if response.status_code == 200 and 'total_slots' in stats and stats['occupied_slots'] == 1:
        print("SUCCESS: Stats endpoint returned correct data.")
    else:
        print("FAILURE: Stats endpoint did not return expected data.")

if __name__ == "__main__":
    register_user()
    auth_token = login_user()
    lot_id = create_parking_lot(auth_token)
    floor_id = create_floor(auth_token, lot_id)
    row_id = create_row(auth_token, lot_id, floor_id)
    slot_id = create_slot(auth_token, lot_id, floor_id, row_id)
    update_slot_status(slot_id)
    verify_slot_status(auth_token, lot_id, slot_id)
    get_lot_stats(auth_token, lot_id) 