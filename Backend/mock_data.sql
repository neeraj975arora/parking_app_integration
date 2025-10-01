-- -- 1) USERS (user_password should be a hashed password; see note below)
-- INSERT INTO users (user_id, user_name, user_email, user_password, user_phone_no, user_address, role) VALUES
-- (1, 'System Super', 'superadmin@example.com', '<HASHED_PASSWORD_SUPER>', '9990001111', 'HQ Building, Main St', 'super_admin'),
-- (2, 'Lot Admin A',  'admin.a@example.com',      '<HASHED_PASSWORD_ADMIN>', '9990002222', 'Lot A Office, Central Mall', 'admin'),
-- (3, 'Regular User', 'user1@example.com',        '<HASHED_PASSWORD_USER>',  '9990003333', 'Customer Address, Apt 101', 'user');

-- 2) PARKING LOTS (parkinglots_details)
INSERT INTO parkinglots_details (
  parkinglot_id, parking_name, city, landmark, address,
  latitude, longitude, car_capacity, available_car_slots,
  two_wheeler_capacity, available_two_wheeler_slots,
  car_parking_charge, two_wheeler_parking_charge, parking_type, payment_modes
) VALUES
(101, 'Central Mall - Basement', 'Mumbai', 'Central Mall', 'Central Mall, Sector 1, Mumbai',
 NULL, NULL, 200, 200, 50, 50, '20/Hour', '5/Hour', 'paid', 'cash,card'),
(102, 'TechPark - Lot 2', 'Bengaluru', 'TechPark Building B', 'TechPark Campus, Building B',
 NULL, NULL, 150, 150, 40, 40, '30/Hour', '10/Hour', 'paid', 'card,upi');

-- 3) FLOORS (one floor per lot for simplicity)
INSERT INTO floors (floor_id, floor_name, parkinglot_id) VALUES
(201, 'Basement-1', 101),
(202, 'Ground', 102);

-- 4) ROWS (one row per floor)  (Not applied to database)
INSERT INTO rows (row_id, row_name, floor_id, parkinglot_id) VALUES
(301, 'Row-A', 201, 101),
(302, 'Row-1', 202, 102);

-- 5) SLOTS  (Not applied to database)
INSERT INTO slots (slot_id, slot_name, status, vehicle_reg_no, ticket_id, row_id, floor_id, parkinglot_id) VALUES
(1001, 'Slot-101', 0, NULL, NULL, 301, 201, 101),
(1002, 'Slot-102', 0, NULL, NULL, 301, 201, 101),
(1003, 'Slot-201', 0, NULL, NULL, 302, 202, 102);

-- 6) ADMIN <-> PARKING LOT assignment (Not applied to database)
-- id is primary key autoincrement; specifying explicit id values is OK for a seed
INSERT INTO admin_parking_lots (id, admin_id, parking_lot_id) VALUES
(1, 2, 101);  -- admin user_id 2 assigned to parkinglot 101

-- 7) PARKING SESSIONS 
INSERT INTO parking_sessions (
  ticket_id, parkinglot_id, floor_id, row_id, slot_id,
  vehicle_reg_no, user_id, start_time, end_time, duration_hrs, amount_paid, vehicle_type
) VALUES
('TKT-0001', 101, 201, 301, 1001, 'DL01AA1001', 3, '2025-08-31 08:30:00', '2025-08-31 10:00:00', 2.0, 40.00, 'car'),
('TKT-0002', 101, 201, 301, 1002, 'MH12BB2002', 3, '2025-09-11 12:00:00', NULL, NULL, NULL, 'car');

-- 8) ADMIN PAYMENT LEDGER (Not applied to database)
INSERT INTO admin_payment_ledger (id, admin_id, date, opening_balance, today_collection, payment_made, closing_balance) VALUES
(1, 2, '2025-09-10', 1000.0, 400.0, 0.0, 1400.0),
(2, 2, '2025-09-11', 1400.0, 250.0, 0.0, 1650.0); 
