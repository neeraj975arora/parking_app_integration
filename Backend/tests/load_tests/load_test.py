"""
Load testing script for the parking application using Locust.
This script tests the performance of the API endpoints under load.
"""

from locust import HttpUser, task, between
import json
import random
import string


class ParkingUser(HttpUser):
    """Simulates a user interacting with the parking system."""
    
    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks
    
    def on_start(self):
        """Called when a user starts. Register and login."""
        self.register_and_login()
    
    def register_and_login(self):
        """Register a new user and login."""
        # Generate random user data
        username = f"loadtest_{random.randint(1000, 9999)}"
        email = f"{username}@loadtest.com"
        password = "loadtest123"
        phone = f"9{random.randint(100000000, 999999999)}"
        
        # Register user
        register_data = {
            "user_name": username,
            "user_email": email,
            "user_password": password,
            "user_phone_no": phone,
            "user_address": "Load Test Address",
            "role": "user"
        }
        
        response = self.client.post("/auth/register", 
                                  data=json.dumps(register_data),
                                  headers={"Content-Type": "application/json"})
        
        if response.status_code == 201:
            # Login user
            login_data = {
                "user_email": email,
                "user_password": password,
                "role": "user"
            }
            
            response = self.client.post("/auth/login",
                                      data=json.dumps(login_data),
                                      headers={"Content-Type": "application/json"})
            
            if response.status_code == 200:
                self.token = response.json()["access_token"]
                self.headers = {"Authorization": f"Bearer {self.token}"}
            else:
                print(f"Login failed: {response.status_code}")
        else:
            print(f"Registration failed: {response.status_code}")
    
    @task(3)
    def get_parking_lots(self):
        """Get all parking lots."""
        self.client.get("/parking/lots", headers=self.headers)
    
    @task(2)
    def create_parking_lot(self):
        """Create a new parking lot."""
        lot_data = {
            "parking_name": f"Load Test Lot {random.randint(100, 999)}",
            "city": "Load Test City",
            "landmark": "Load Test Landmark",
            "address": "Load Test Address",
            "latitude": round(random.uniform(12.0, 13.0), 6),
            "longitude": round(random.uniform(77.0, 78.0), 6),
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
            "car_capacity": random.randint(10, 50),
            "available_car_slots": random.randint(5, 25),
            "two_wheeler_capacity": random.randint(5, 30),
            "available_two_wheeler_slots": random.randint(2, 15),
            "parking_type": "Open",
            "payment_modes": "Cash,Card,UPI",
            "car_parking_charge": f"{random.randint(20, 50)}/hr",
            "two_wheeler_parking_charge": f"{random.randint(10, 30)}/hr",
            "allows_prepaid_passes": "Yes",
            "provides_valet_services": "No",
            "value_added_services": "Smart Parking"
        }
        
        self.client.post("/parking/lots", 
                        data=json.dumps(lot_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def get_slots(self):
        """Get parking slots."""
        self.client.get("/parking/slots", headers=self.headers)
    
    @task(1)
    def create_floor(self):
        """Create a floor for a parking lot."""
        floor_data = {
            "floor_name": f"Floor {random.randint(1, 5)}",
            "parkinglot_id": random.randint(1, 10)  # Assuming some lots exist
        }
        
        self.client.post("/parking/floors",
                        data=json.dumps(floor_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def create_row(self):
        """Create a row for a floor."""
        row_data = {
            "row_name": f"Row {random.randint(1, 10)}",
            "floor_id": random.randint(1, 5),  # Assuming some floors exist
            "parkinglot_id": random.randint(1, 10)
        }
        
        self.client.post("/parking/rows",
                        data=json.dumps(row_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(2)
    def create_slot(self):
        """Create a parking slot."""
        slot_data = {
            "slot_name": f"Slot {random.randint(1, 100)}",
            "row_id": random.randint(1, 10),  # Assuming some rows exist
            "floor_id": random.randint(1, 5),
            "parkinglot_id": random.randint(1, 10)
        }
        
        self.client.post("/parking/slots",
                        data=json.dumps(slot_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def update_slot_status(self):
        """Update slot status via IoT API."""
        slot_id = random.randint(1, 50)  # Assuming some slots exist
        status = random.choice([0, 1])
        
        update_data = {
            "id": slot_id,
            "status": status
        }
        
        # Use API key for IoT device simulation
        iot_headers = {
            "Content-Type": "application/json",
            "X-API-Key": "super-secret-rpi-key"
        }
        
        self.client.post("/api/v1/slots/update_status",
                        data=json.dumps(update_data),
                        headers=iot_headers)


class AdminUser(HttpUser):
    """Simulates an admin user interacting with the system."""
    
    wait_time = between(2, 5)
    
    def on_start(self):
        """Register as super admin and login."""
        self.register_super_admin()
    
    def register_super_admin(self):
        """Register as super admin."""
        admin_data = {
            "user_name": f"admin_{random.randint(1000, 9999)}",
            "user_email": f"admin_{random.randint(1000, 9999)}@loadtest.com",
            "user_password": "admin123",
            "user_phone_no": f"8{random.randint(100000000, 999999999)}",
            "user_address": "Admin Load Test Address",
            "role": "super_admin"
        }
        
        response = self.client.post("/auth/register",
                                  data=json.dumps(admin_data),
                                  headers={"Content-Type": "application/json"})
        
        if response.status_code == 201:
            # Login as super admin
            login_data = {
                "user_email": admin_data["user_email"],
                "user_password": admin_data["user_password"],
                "role": "super_admin"
            }
            
            response = self.client.post("/auth/login",
                                      data=json.dumps(login_data),
                                      headers={"Content-Type": "application/json"})
            
            if response.status_code == 200:
                self.token = response.json()["access_token"]
                self.headers = {"Authorization": f"Bearer {self.token}"}
    
    @task(2)
    def get_admin_lots(self):
        """Get admin assigned lots."""
        self.client.get("/admin/lots", headers=self.headers)
    
    @task(1)
    def assign_admin_lot(self):
        """Assign a lot to an admin."""
        assignment_data = {
            "admin_id": random.randint(1, 5),
            "parking_lot_id": random.randint(1, 10),
            "assigned_date": "2024-01-01"
        }
        
        self.client.post("/admin/assign-lot",
                        data=json.dumps(assignment_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def vehicle_checkin(self):
        """Simulate vehicle check-in."""
        checkin_data = {
            "admin_id": random.randint(1, 5),
            "vehicle_reg_no": f"DL{random.randint(1000, 9999)}{random.choice(string.ascii_uppercase)}{random.randint(1000, 9999)}",
            "vehicle_type": random.choice(["Car", "Bike"]),
            "slot_id": random.randint(1, 50)
        }
        
        self.client.post("/admin/checkin",
                        data=json.dumps(checkin_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def vehicle_checkout(self):
        """Simulate vehicle check-out."""
        checkout_data = {
            "admin_id": random.randint(1, 5),
            "vehicle_reg_no": f"DL{random.randint(1000, 9999)}{random.choice(string.ascii_uppercase)}{random.randint(1000, 9999)}",
            "amount_paid": round(random.uniform(10.0, 100.0), 2)
        }
        
        self.client.post("/admin/checkout",
                        data=json.dumps(checkout_data),
                        headers={**self.headers, "Content-Type": "application/json"})
    
    @task(1)
    def daily_closure(self):
        """Simulate daily closure."""
        closure_data = {
            "admin_id": random.randint(1, 5),
            "date": "2024-01-01",
            "opening_balance": round(random.uniform(0, 1000), 2),
            "today_collection": round(random.uniform(100, 2000), 2),
            "payment_made": round(random.uniform(50, 500), 2),
            "closing_balance": round(random.uniform(0, 2000), 2)
        }
        
        self.client.post("/admin/closure",
                        data=json.dumps(closure_data),
                        headers={**self.headers, "Content-Type": "application/json"})
