-- Users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) UNIQUE NOT NULL,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    user_password VARCHAR(255) NOT NULL,
    user_phone_no VARCHAR(15) UNIQUE NOT NULL,
    user_address TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',  -- 'user', 'admin', 'super_admin'
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parking Lot Details
CREATE TABLE parkinglots_details (
    parkinglot_id SERIAL PRIMARY KEY,
    parking_name TEXT,
    city TEXT,
    landmark TEXT,
    address TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    physical_appearance TEXT,
    parking_ownership TEXT,
    parking_surface TEXT,
    has_cctv TEXT,
    has_boom_barrier TEXT,
    ticket_generated TEXT,
    entry_exit_gates TEXT,
    weekly_off TEXT,
    parking_timing TEXT,
    vehicle_types TEXT,
    car_capacity INTEGER,
    available_car_slots INTEGER,
    two_wheeler_capacity INTEGER,
    available_two_wheeler_slots INTEGER,
    parking_type TEXT,
    payment_modes TEXT,
    car_parking_charge TEXT,
    two_wheeler_parking_charge TEXT,
    allows_prepaid_passes TEXT,
    provides_valet_services TEXT,
    value_added_services TEXT
);

-- Floors
CREATE TABLE floors (
    floor_id SERIAL PRIMARY KEY,
    floor_name VARCHAR(50) NOT NULL,
    parkinglot_id INTEGER NOT NULL REFERENCES parkinglots_details(parkinglot_id) ON DELETE CASCADE
);

-- Rows
CREATE TABLE rows (
    row_id SERIAL PRIMARY KEY,
    row_name VARCHAR(50) NOT NULL,
    floor_id INTEGER NOT NULL REFERENCES floors(floor_id) ON DELETE CASCADE,
    parkinglot_id INTEGER NOT NULL -- denormalized field
);

-- Slots
CREATE TABLE slots (
    slot_id SERIAL PRIMARY KEY,
    slot_name VARCHAR(50) NOT NULL,
    status INTEGER DEFAULT 0,  -- 0 free, 1 occupied
    vehicle_reg_no VARCHAR(20),
    ticket_id VARCHAR(50),
    row_id INTEGER NOT NULL REFERENCES rows(row_id) ON DELETE CASCADE,
    floor_id INTEGER NOT NULL,
    parkinglot_id INTEGER NOT NULL
);

-- Parking Sessions
CREATE TABLE parking_sessions (
    ticket_id VARCHAR(50) PRIMARY KEY,
    parkinglot_id INTEGER,
    floor_id INTEGER,
    row_id INTEGER,
    slot_id INTEGER REFERENCES slots(slot_id) ON DELETE SET NULL,
    vehicle_reg_no VARCHAR(20) NOT NULL,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    duration_hrs NUMERIC,
    amount_paid NUMERIC(10,2) DEFAULT 0,
    vehicle_type VARCHAR(20)
);

-- Admin Parking Lots
CREATE TABLE admin_parking_lots (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    parking_lot_id INTEGER NOT NULL REFERENCES parkinglots_details(parkinglot_id) ON DELETE CASCADE,
    assigned_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Admin Payment Ledger
CREATE TABLE admin_payment_ledger (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    date DATE NOT NULL,
    opening_balance FLOAT NOT NULL DEFAULT 0.0,
    today_collection FLOAT NOT NULL DEFAULT 0.0,
    payment_made FLOAT NOT NULL DEFAULT 0.0,
    closing_balance FLOAT NOT NULL DEFAULT 0.0,
    CONSTRAINT uix_admin_date UNIQUE (admin_id, date)
);

