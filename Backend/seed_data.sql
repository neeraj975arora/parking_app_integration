-- Reset all data before seeding
TRUNCATE admin_payment_ledger,
         parking_sessions,
         admin_parking_lots,
         slots,
         rows,
         floors,
         parkinglots_details,
         users
RESTART IDENTITY CASCADE;

-- ===========================
-- 1) USERS
-- ===========================
-- Superadmin
INSERT INTO users (user_id, user_name, user_email, user_password, user_phone_no, user_address, role, created_on)
VALUES
(1, 'superadmin', 'superadmin@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '9009244409', 'Impressico', 'super_admin', now() - INTERVAL '90 days'),
(10, 'admin10', 'admin10@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000110', 'Admin Office 10', 'admin', now() - INTERVAL '90 days'),
(11, 'admin11', 'admin11@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000111', 'Admin Office 11', 'admin', now() - INTERVAL '89 days'),
(12, 'admin12', 'admin12@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000112', 'Admin Office 12', 'admin', now() - INTERVAL '88 days'),
(13, 'admin13', 'admin13@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000113', 'Admin Office 13', 'admin', now() - INTERVAL '87 days'),
(14, 'admin14', 'admin14@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000114', 'Admin Office 14', 'admin', now() - INTERVAL '86 days'),
(15, 'admin15', 'admin15@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000115', 'Admin Office 15', 'admin', now() - INTERVAL '85 days'),
(16, 'admin16', 'admin16@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000116', 'Admin Office 16', 'admin', now() - INTERVAL '84 days'),
(17, 'admin17', 'admin17@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000117', 'Admin Office 17', 'admin', now() - INTERVAL '83 days'),
(18, 'admin18', 'admin18@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000118', 'Admin Office 18', 'admin', now() - INTERVAL '82 days'),
(19, 'admin19', 'admin19@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91900000119', 'Admin Office 19', 'admin', now() - INTERVAL '81 days'),
(20, 'user20', 'user20@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000220', 'User Address 20', 'user', now() - INTERVAL '90 days'),
(21, 'user21', 'user21@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000221', 'User Address 21', 'user', now() - INTERVAL '89 days'),
(22, 'user22', 'user22@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000222', 'User Address 22', 'user', now() - INTERVAL '88 days'),
(23, 'user23', 'user23@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000223', 'User Address 23', 'user', now() - INTERVAL '87 days'),
(24, 'user24', 'user24@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000224', 'User Address 24', 'user', now() - INTERVAL '86 days'),
(25, 'user25', 'user25@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000225', 'User Address 25', 'user', now() - INTERVAL '85 days'),
(26, 'user26', 'user26@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000226', 'User Address 26', 'user', now() - INTERVAL '84 days'),
(27, 'user27', 'user27@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000227', 'User Address 27', 'user', now() - INTERVAL '83 days'),
(28, 'user28', 'user28@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000228', 'User Address 28', 'user', now() - INTERVAL '82 days'),
(29, 'user29', 'user29@parking.com', 'scrypt:32768:8:1$GaMG6bFAxMO1ate5$e918a348b3fa96accf2954613b74692548218702a63dd24928e269407ce904bbd7d088643e45e261a95b52f58bc41c3609d9ef3de9bb9a7abe87ce9d6efcb463', '+91910000229', 'User Address 29', 'user', now() - INTERVAL '81 days');
-- 2) PARKING LOTS (10)
-- ===========================
-- Corrected parkinglots_details (10 rows) - each tuple has exactly the same number of values
INSERT INTO parkinglots_details (
    parkinglot_id, parking_name, city, landmark, address, latitude, longitude,
    physical_appearance, parking_ownership, parking_surface, has_cctv, has_boom_barrier,
    ticket_generated, entry_exit_gates, weekly_off, parking_timing, vehicle_types,
    car_capacity, available_car_slots, two_wheeler_capacity, available_two_wheeler_slots,
    parking_type, payment_modes, car_parking_charge, two_wheeler_parking_charge,
    allows_prepaid_passes, provides_valet_services, value_added_services
) VALUES
(1, 'Nariman Point Parking', 'Mumbai', 'Near Marine Drive', 'Nariman Point, Mumbai', 18.920388, 72.830130,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'None', '24/7', 'car,motorcycle',
 50, 15, 30, 10, 'commercial', 'cash,card,digital', '50 for first 2 hours, 20 thereafter', '20 for first 2 hours, 10 thereafter',
 'Yes', 'No', 'CCTV, Security, Washroom'),

(2, 'Bandra West Parking', 'Mumbai', 'Near Linking Road', 'Bandra West, Mumbai', 19.0520, 72.8300,
 'Open-lot', 'Private', 'Asphalt', 'Yes', 'No', 'No', 'Multiple', 'Sunday', '08:00-22:00', 'car,motorcycle',
 80, 40, 60, 25, 'commercial', 'cash,card', '40 per 2 hours', '15 per 2 hours',
 'Yes', 'Yes', 'CCTV, Security'),

(3, 'Andheri East Multi', 'Mumbai', 'Near Airport', 'Andheri East, Mumbai', 19.0896, 72.8656,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'Sunday', '24/7', 'car,motorcycle',
 120, 70, 80, 30, 'commercial', 'card,digital', '60 for first 2 hours, 25 thereafter', '25 for first 2 hours, 12 thereafter',
 'Yes', 'Yes', 'CCTV, Valet'),

(4, 'MG Road Parking', 'Bengaluru', 'Near MG Road', 'MG Road, Bengaluru', 12.9721, 77.5933,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'None', '07:00-23:00', 'car,motorcycle',
 100, 50, 50, 20, 'commercial', 'cash,card,digital', '50 for first 2 hours, 20 thereafter', '20 for first 2 hours, 10 thereafter',
 'Yes', 'No', 'CCTV, Security, EV Charging'),

(5, 'Koramangala Parking', 'Bengaluru', 'Near Forum Mall', 'Koramangala, Bengaluru', 12.9346, 77.6140,
 'Open-lot', 'Private', 'Asphalt', 'No', 'No', 'No', 'Multiple', 'Sunday', '09:00-22:00', 'car,motorcycle',
 70, 30, 60, 20, 'commercial', 'cash,card', '40 flat', '15 flat',
 'No', 'No', 'Security'),

(6, 'DLF Cyber Hub Parking', 'Gurgaon', 'Near Cyber Hub', 'DLF Cyber Hub, Gurgaon', 28.5046, 77.0891,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'Sunday', '10:00-02:00', 'car,motorcycle',
 150, 120, 100, 70, 'commercial', 'card,digital', '80 for first 2 hours', '30 for first 2 hours',
 'Yes', 'Yes', 'CCTV, Valet, EV'),

(7, 'Connaught Place Parking', 'New Delhi', 'Near CP', 'Connaught Place, New Delhi', 28.6329, 77.2188,
 'Underground', 'Public', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'None', '24/7', 'car,motorcycle',
 200, 150, 80, 50, 'commercial', 'cash,card,digital', '100 for first 3 hours', '40 for first 3 hours',
 'Yes', 'No', 'CCTV, Security, EV'),

(8, 'Park Street Parking', 'Kolkata', 'Near Park Street', 'Park Street, Kolkata', 22.5597, 88.3636,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'No', 'Yes', 'Separate', 'Sunday', '08:00-23:00', 'car,motorcycle',
 90, 45, 50, 20, 'commercial', 'cash,card', '45 for first 2 hours', '18 for first 2 hours',
 'Yes', 'No', 'CCTV, Security'),

(9, 'Pune Camp Parking', 'Pune', 'Near Pune Station', 'Pune Camp, Pune', 18.5204, 73.8567,
 'Open-lot', 'Private', 'Asphalt', 'No', 'No', 'No', 'Multiple', 'Sunday', '06:00-23:00', 'car,motorcycle',
 60, 20, 40, 10, 'commercial', 'cash', '30 flat', '10 flat',
 'No', 'No', 'Security'),

(10, 'Chennai Marina Parking', 'Chennai', 'Near Marina Beach', 'Marina Beach, Chennai', 13.0489, 80.2824,
 'Multi-level', 'Private', 'Concrete', 'Yes', 'Yes', 'Yes', 'Separate', 'None', '24/7', 'car,motorcycle',
 110, 70, 60, 30, 'commercial', 'card,digital', '55 for first 2 hours', '22 for first 2 hours',
 'Yes', 'Yes', 'CCTV, Security, Valet');


-- ===========================
-- 3) FLOORS, ROWS, SLOTS
--    Assumption: each parking lot has 3 floors (Ground, 1, 2),
--                each floor has 4 rows (A,B,C,D),
--                each row has 10 slots (slot numbers 1..10).
--    Deterministic id scheme:
--      floor_id  = parkinglot_id * 100 + floor_index (1..3)
--      row_id    = floor_id * 10 + row_index (1..4)
--      slot_id   = row_id * 100 + slot_index (1..10)
-- ===========================

-- Insert Floors (explicit ids so we can reference them deterministically)
INSERT INTO floors (floor_id, floor_name, parkinglot_id) VALUES
(101, 'Ground', 1), (102, 'First', 1), (103, 'Second', 1),
(201, 'Ground', 2), (202, 'First', 2), (203, 'Second', 2),
(301, 'Ground', 3), (302, 'First', 3), (303, 'Second', 3),
(401, 'Ground', 4), (402, 'First', 4), (403, 'Second', 4),
(501, 'Ground', 5), (502, 'First', 5), (503, 'Second', 5),
(601, 'Ground', 6), (602, 'First', 6), (603, 'Second', 6),
(701, 'Ground', 7), (702, 'First', 7), (703, 'Second', 7),
(801, 'Ground', 8), (802, 'First', 8), (803, 'Second', 8),
(901, 'Ground', 9), (902, 'First', 9), (903, 'Second', 9),
(1001, 'Ground', 10), (1002, 'First', 10), (1003, 'Second', 10);

-- Insert Rows (4 rows per floor)
-- row_name pattern: Row-A, Row-B, Row-C, Row-D
INSERT INTO rows (row_id, row_name, floor_id, parkinglot_id) VALUES
-- parkinglot 1 floors 101..103
(1011, 'Row-A', 101, 1), (1012, 'Row-B', 101, 1), (1013, 'Row-C', 101, 1), (1014, 'Row-D', 101, 1),
(1021, 'Row-A', 102, 1), (1022, 'Row-B', 102, 1), (1023, 'Row-C', 102, 1), (1024, 'Row-D', 102, 1),
(1031, 'Row-A', 103, 1), (1032, 'Row-B', 103, 1), (1033, 'Row-C', 103, 1), (1034, 'Row-D', 103, 1),

-- parkinglot 2 floors 201..203
(2011, 'Row-A', 201, 2), (2012, 'Row-B', 201, 2), (2013, 'Row-C', 201, 2), (2014, 'Row-D', 201, 2),
(2021, 'Row-A', 202, 2), (2022, 'Row-B', 202, 2), (2023, 'Row-C', 202, 2), (2024, 'Row-D', 202, 2),
(2031, 'Row-A', 203, 2), (2032, 'Row-B', 203, 2), (2033, 'Row-C', 203, 2), (2034, 'Row-D', 203, 2),

-- parkinglot 3 floors 301..303
(3011, 'Row-A', 301, 3), (3012, 'Row-B', 301, 3), (3013, 'Row-C', 301, 3), (3014, 'Row-D', 301, 3),
(3021, 'Row-A', 302, 3), (3022, 'Row-B', 302, 3), (3023, 'Row-C', 302, 3), (3024, 'Row-D', 302, 3),
(3031, 'Row-A', 303, 3), (3032, 'Row-B', 303, 3), (3033, 'Row-C', 303, 3), (3034, 'Row-D', 303, 3),

-- parkinglot 4
(4011, 'Row-A', 401, 4), (4012, 'Row-B', 401, 4), (4013, 'Row-C', 401, 4), (4014, 'Row-D', 401, 4),
(4021, 'Row-A', 402, 4), (4022, 'Row-B', 402, 4), (4023, 'Row-C', 402, 4), (4024, 'Row-D', 402, 4),
(4031, 'Row-A', 403, 4), (4032, 'Row-B', 403, 4), (4033, 'Row-C', 403, 4), (4034, 'Row-D', 403, 4),

-- parkinglot 5
(5011, 'Row-A', 501, 5), (5012, 'Row-B', 501, 5), (5013, 'Row-C', 501, 5), (5014, 'Row-D', 501, 5),
(5021, 'Row-A', 502, 5), (5022, 'Row-B', 502, 5), (5023, 'Row-C', 502, 5), (5024, 'Row-D', 502, 5),
(5031, 'Row-A', 503, 5), (5032, 'Row-B', 503, 5), (5033, 'Row-C', 503, 5), (5034, 'Row-D', 503, 5),

-- parkinglot 6
(6011, 'Row-A', 601, 6), (6012, 'Row-B', 601, 6), (6013, 'Row-C', 601, 6), (6014, 'Row-D', 601, 6),
(6021, 'Row-A', 602, 6), (6022, 'Row-B', 602, 6), (6023, 'Row-C', 602, 6), (6024, 'Row-D', 602, 6),
(6031, 'Row-A', 603, 6), (6032, 'Row-B', 603, 6), (6033, 'Row-C', 603, 6), (6034, 'Row-D', 603, 6),

-- parkinglot 7
(7011, 'Row-A', 701, 7), (7012, 'Row-B', 701, 7), (7013, 'Row-C', 701, 7), (7014, 'Row-D', 701, 7),
(7021, 'Row-A', 702, 7), (7022, 'Row-B', 702, 7), (7023, 'Row-C', 702, 7), (7024, 'Row-D', 702, 7),
(7031, 'Row-A', 703, 7), (7032, 'Row-B', 703, 7), (7033, 'Row-C', 703, 7), (7034, 'Row-D', 703, 7),

-- parkinglot 8
(8011, 'Row-A', 801, 8), (8012, 'Row-B', 801, 8), (8013, 'Row-C', 801, 8), (8014, 'Row-D', 801, 8),
(8021, 'Row-A', 802, 8), (8022, 'Row-B', 802, 8), (8023, 'Row-C', 802, 8), (8024, 'Row-D', 802, 8),
(8031, 'Row-A', 803, 8), (8032, 'Row-B', 803, 8), (8033, 'Row-C', 803, 8), (8034, 'Row-D', 803, 8),

-- parkinglot 9
(9011, 'Row-A', 901, 9), (9012, 'Row-B', 901, 9), (9013, 'Row-C', 901, 9), (9014, 'Row-D', 901, 9),
(9021, 'Row-A', 902, 9), (9022, 'Row-B', 902, 9), (9023, 'Row-C', 902, 9), (9024, 'Row-D', 902, 9),
(9031, 'Row-A', 903, 9), (9032, 'Row-B', 903, 9), (9033, 'Row-C', 903, 9), (9034, 'Row-D', 903, 9),

-- parkinglot 10
(10011, 'Row-A', 1001, 10), (10012, 'Row-B', 1001, 10), (10013, 'Row-C', 1001, 10), (10014, 'Row-D', 1001, 10),
(10021, 'Row-A', 1002, 10), (10022, 'Row-B', 1002, 10), (10023, 'Row-C', 1002, 10), (10024, 'Row-D', 1002, 10),
(10031, 'Row-A', 1003, 10), (10032, 'Row-B', 1003, 10), (10033, 'Row-C', 1003, 10), (10034, 'Row-D', 1003, 10);


-- Insert Slots: 10 slots per row (slot indexes 1..10)
-- slot_id = row_id * 100 + slot_index
-- slot_name e.g. "S1", "S2", ...
-- default status = 0 (free)
-- We'll insert for each row listed above. To keep the file reasonable, do a concise set generation using a DO block.

DO $$
DECLARE
    r RECORD;
    i INT;
BEGIN
    FOR r IN SELECT row_id, floor_id, parkinglot_id FROM rows LOOP
        FOR i IN 1..10 LOOP
            INSERT INTO slots(slot_id, slot_name, status, row_id, floor_id, parkinglot_id)
            VALUES (r.row_id * 100 + i, 'S' || i, 0, r.row_id, r.floor_id, r.parkinglot_id);
        END LOOP;
    END LOOP;
END$$;

-- ===========================
-- 4) ASSIGN EACH PARKING LOT TO AN ADMIN
--    (admin_id 10..19 -> parking_lot_id 1..10)
-- ===========================
INSERT INTO admin_parking_lots (admin_id, parking_lot_id, assigned_date) VALUES
(10, 1, now() - INTERVAL '85 days'),
(11, 2, now() - INTERVAL '80 days'),
(12, 3, now() - INTERVAL '75 days'),
(13, 4, now() - INTERVAL '70 days'),
(14, 5, now() - INTERVAL '65 days'),
(15, 6, now() - INTERVAL '60 days'),
(16, 7, now() - INTERVAL '55 days'),
(17, 8, now() - INTERVAL '50 days'),
(18, 9, now() - INTERVAL '45 days'),
(19, 10, now() - INTERVAL '40 days');


-- ===========================
-- 5) PARKING SESSIONS: generate 100 sessions across last ~90 days
--    We use a single INSERT ... SELECT from generate_series(1,100)
--    Assumptions:
--      - ticket_id: 'TICKET-XXXX'
--      - parkinglot_id cycles 1..10
--      - floor_id chosen deterministically from parkinglot (p*100 + ((s-1)%3)+1)
--      - row_id and slot_id computed accordingly (matching the rows/slots we inserted)
--      - user_id cycles through 20..29
--      - start_time is now() - random 0..89 days - random hours/minutes
--      - end_time = start_time + random 30..300 minutes (some sessions may be ongoing: 10% null end_time)
--      - duration_hrs computed when end_time is not null
--      - amount_paid approximated as ceil(duration_hrs) * a rate (flat 30 for two-wheelers, 60 for cars)
--      - vehicle_type chosen 'Car' (70%) or 'Two-Wheeler' (30%)
-- ===========================
-- ===========================
-- 5) PARKING SESSIONS: generate 100 sessions across last ~90 days
-- ===========================
-- ===========================
-- 5) PARKING SESSIONS: generate 100 sessions with realistic small values
-- ===========================
INSERT INTO parking_sessions (
  ticket_id, parkinglot_id, floor_id, row_id, slot_id,
  vehicle_reg_no, user_id, start_time, end_time, duration_hrs, amount_paid, vehicle_type
)
SELECT
  'TICKET-' || LPAD(s::text, 4, '0'),
  p AS parkinglot_id,
  f.floor_id,
  r.row_id,
  r.row_id * 100 + ((s-1)%10 + 1) AS slot_id,
  'MH' || LPAD((100 + ((s*7)%900))::text, 3, '0') || '-XY' || LPAD(s::text,4,'0'),
  20 + ((s-1) % 10) AS user_id,
  now() - (floor(random()*30) || ' days')::interval - (floor(random()*24) || ' hours')::interval - (floor(random()*60) || ' minutes')::interval AS start_time,
  CASE WHEN random() < 0.85
       THEN now() - (floor(random()*30) || ' days')::interval + (15 + floor(random()*180)) * INTERVAL '1 minute'
       ELSE NULL
  END AS end_time,
  CASE 
      WHEN random() < 0.85 THEN 
        -- Realistic duration: 0.5 to 8 hours, rounded up to next hour
        GREATEST(1, CEIL((0.5 + random() * 7.5)::numeric))
      ELSE NULL
  END AS duration_hrs,
  CASE 
      WHEN random() < 0.5 THEN 
        -- Car: 30 Rs/hour, minimum 1 hour, rounded up
        GREATEST(1, CEIL((0.5 + random() * 7.5)::numeric)) * 30
      WHEN random() < 0.8 THEN 
        -- Two-Wheeler: 20 Rs/hour, minimum 1 hour, rounded up
        GREATEST(1, CEIL((0.5 + random() * 7.5)::numeric)) * 20
      ELSE 
        -- Three-Wheeler: 30 Rs/hour, minimum 1 hour, rounded up
        GREATEST(1, CEIL((0.5 + random() * 7.5)::numeric)) * 30
  END AS amount_paid,
  CASE 
      WHEN random() < 0.5 THEN 'Car' 
      WHEN random() < 0.8 THEN 'Two-Wheeler' 
      ELSE 'Three-Wheeler' 
  END AS vehicle_type
FROM generate_series(1,100) AS s
CROSS JOIN (SELECT generate_series(1,10) AS p) AS t
JOIN floors f ON f.parkinglot_id = t.p
JOIN rows r ON r.floor_id = f.floor_id
LIMIT 100;



-- ===========================
-- 6) ADMIN PAYMENT LEDGER (realistic small values)
-- ===========================
INSERT INTO admin_payment_ledger (admin_id, date, opening_balance, today_collection, payment_made, closing_balance)
VALUES
(10, current_date, 0, 450, 400, 50),
(11, current_date, 0, 380, 350, 30),
(12, current_date, 0, 520, 480, 40),
(13, current_date, 0, 340, 300, 40),
(14, current_date, 0, 480, 450, 30),
(15, current_date, 0, 290, 250, 40),
(16, current_date, 0, 410, 380, 30),
(17, current_date, 0, 360, 320, 40),
(18, current_date, 0, 390, 350, 40),
(19, current_date, 0, 420, 390, 30);

-- DO $$
-- DECLARE
--     a_id INT;
--     d DATE;
--     ob NUMERIC(10,2);
--     tc NUMERIC(10,2);
--     pm NUMERIC(10,2);
--     cb NUMERIC(10,2);
-- BEGIN
--     FOR a_id IN 10..19 LOOP
--         ob := 0;
--         FOR d IN (SELECT generate_series(current_date - interval '89 days', current_date, interval '1 day')) LOOP
--             tc := 1000 + floor(random()*4000); -- 1000–5000
--             pm := 800 + floor(random()*3200);  -- 800–4000
--             cb := ob + tc - pm;
--             INSERT INTO admin_payment_ledger (admin_id, date, opening_balance, today_collection, payment_made, closing_balance)
--             VALUES (a_id, d, ob, tc, pm, cb);
--             ob := cb; -- next day's opening_balance = today's closing_balance
--         END LOOP;
--     END LOOP;
-- END$$;


-- ===========================
-- 7) UPDATE SEQUENCES
-- ===========================
SELECT setval(pg_get_serial_sequence('users', 'user_id'), (SELECT MAX(user_id) FROM users));
SELECT setval(pg_get_serial_sequence('parkinglots_details', 'parkinglot_id'), (SELECT MAX(parkinglot_id) FROM parkinglots_details));
SELECT setval(pg_get_serial_sequence('floors', 'floor_id'), (SELECT MAX(floor_id) FROM floors));
SELECT setval(pg_get_serial_sequence('rows', 'row_id'), (SELECT MAX(row_id) FROM rows));
SELECT setval(pg_get_serial_sequence('admin_parking_lots','id'), (SELECT MAX(id) FROM admin_parking_lots));
SELECT setval(pg_get_serial_sequence('admin_payment_ledger','id'), (SELECT MAX(id) FROM admin_payment_ledger));
SELECT setval(pg_get_serial_sequence('slots', 'slot_id'), (SELECT MAX(slot_id) FROM slots));



-- ===========================
-- 6) ADMIN PAYMENT LEDGER (90 days history per admin)
-- ===========================
-- Assumptions:
--   - Each admin has daily ledger for last 90 days
--   - opening_balance is yesterday's closing_balance
--   - today_collection random 1000–5000
--   - payment_made random 800–4000
--   - closing_balance = opening_balance + today_collection - payment_made
--   - ensures unique (admin_id, date) rows
