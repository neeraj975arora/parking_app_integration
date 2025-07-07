from . import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class ParkingLotDetails(db.Model):
    __tablename__ = 'parkinglots_details'
    id = db.Column('parkinglot_id', db.Integer, primary_key=True)
    name = db.Column('parking_name', db.Text)
    city = db.Column(db.Text)
    landmark = db.Column(db.Text)
    address = db.Column(db.Text)
    latitude = db.Column(db.Numeric)
    longitude = db.Column(db.Numeric)
    physical_appearance = db.Column(db.Text)
    parking_ownership = db.Column(db.Text)
    parking_surface = db.Column(db.Text)
    has_cctv = db.Column(db.Text)
    has_boom_barrier = db.Column(db.Text)
    ticket_generated = db.Column(db.Text)
    entry_exit_gates = db.Column(db.Text)
    weekly_off = db.Column(db.Text)
    parking_timing = db.Column(db.Text)
    vehicle_types = db.Column(db.Text)
    car_capacity = db.Column(db.Integer)
    available_car_slots = db.Column(db.Integer)
    two_wheeler_capacity = db.Column(db.Integer)
    available_two_wheeler_slots = db.Column(db.Integer)
    parking_type = db.Column(db.Text)
    payment_modes = db.Column(db.Text)
    car_parking_charge = db.Column(db.Text)
    two_wheeler_parking_charge = db.Column(db.Text)
    allows_prepaid_passes = db.Column(db.Text)
    provides_valet_services = db.Column(db.Text)
    value_added_services = db.Column(db.Text)

    floors = db.relationship('Floor', backref='parking_lot', lazy=True)

class User(db.Model):
    __tablename__ = 'users'
    user_id = db.Column(db.Integer, primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    user_email = db.Column(db.String(100), unique=True, nullable=False)
    user_password = db.Column(db.String(255), nullable=False)
    user_phone_no = db.Column(db.String(15), unique=True, nullable=False)
    user_address = db.Column(db.Text)

    sessions = db.relationship('ParkingSession', backref='user', lazy=True)

    def set_password(self, password):
        self.user_password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.user_password, password)

class Floor(db.Model):
    __tablename__ = 'floors'
    id = db.Column('floor_id', db.Integer, primary_key=True)
    name = db.Column('floor_name', db.String(50), nullable=False)
    parkinglot_id = db.Column(db.Integer, db.ForeignKey('parkinglots_details.parkinglot_id'), nullable=False)

    rows = db.relationship('Row', backref='floor', lazy=True)

class Row(db.Model):
    __tablename__ = 'rows'
    id = db.Column('row_id', db.Integer, primary_key=True)
    name = db.Column('row_name', db.String(50), nullable=False)
    floor_id = db.Column(db.Integer, db.ForeignKey('floors.floor_id'), nullable=False)
    parkinglot_id = db.Column(db.Integer, nullable=False) # Denormalized for easier lookup

    slots = db.relationship('Slot', backref='row', lazy=True)

class Slot(db.Model):
    __tablename__ = 'slots'
    id = db.Column('slot_id', db.Integer, primary_key=True)
    name = db.Column('slot_name', db.String(50), nullable=False)
    status = db.Column(db.Integer, default=0) # 0 for free, 1 for occupied
    vehicle_reg_no = db.Column(db.String(20))
    ticket_id = db.Column(db.String(50))
    row_id = db.Column(db.Integer, db.ForeignKey('rows.row_id'), nullable=False)
    floor_id = db.Column(db.Integer, nullable=False) # Denormalized
    parkinglot_id = db.Column(db.Integer, nullable=False) # Denormalized

class ParkingSession(db.Model):
    __tablename__ = 'parking_sessions'
    ticket_id = db.Column(db.String(50), primary_key=True)
    parkinglot_id = db.Column(db.Integer)
    floor_id = db.Column(db.Integer)
    row_id = db.Column(db.Integer)
    slot_id = db.Column(db.Integer, db.ForeignKey('slots.slot_id'))
    vehicle_reg_no = db.Column(db.String(20), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.user_id'))
    start_time = db.Column(db.DateTime, default=datetime.utcnow)
    end_time = db.Column(db.DateTime)
    duration_hrs = db.Column(db.Numeric, server_default=None) 