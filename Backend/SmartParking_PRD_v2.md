# Smart Parking Cloud Server – Product Requirements Document

**Last Updated:** 2025-07-04  
**Maintainer:** Shubham Goyal  
**Project:** Vision Parking App – Centralized Cloud Server

---

## 📦 Version 1.0 – Core Features (Existing)

### ✅ Real-Time Slot Tracking
Tracks availability of parking slots using YOLO/OpenCV on Raspberry Pi and syncs status with cloud server.

### ✅ Hierarchical Parking Lot Management
Supports nested models: `ParkingLot → Floor → Row → Slot`. Flexible handling of large parking structures.

### ✅ REST API for Mobile App & Admin Dashboard
Flask-based backend providing authenticated endpoints using JWT for both drivers and parking admins.

### ✅ Dockerized Infrastructure
Full Docker + Compose deployment for PostgreSQL, Flask App, and Nginx.

### ✅ IoT Integration (API Key)
Dedicated API key-secured endpoints for Raspberry Pi to push parking slot status.

### ✅ User Personas & Flows
- **Driver Flow:** Search → Slot Status → Park → Exit  
- **Admin Flow:** Dashboard → View Lots/Floors/Rows → View Logs

---

## 🚀 Version 2.0 – Admin Enhancements & Session Tracking

### 🔒 Admin Role Management
- Added `role` field to `users` table: (`user`, `admin`)
- Admins can control one or more parking lots.

### 🅿️ Admin-to-Lot Mapping
- New table `admin_parking_lots` to map multiple lots per admin.

### 📥 Vehicle Check-In API
- Begins a new `ParkingSession` upon entry.
- Captures check-in time and vehicle details.

### 📤 Vehicle Check-Out API
- Ends session, calculates amount due based on parking lot's hourly rate.
- Stores payment amount and timestamp.


### 🔄 Vehicle Type Support for Billing
- Added `vehicle_type` field to `ParkingSession`.
- Used to differentiate rates between `Car` and `Two-Wheeler` during check-out.


### 💰 Admin Payment Ledger
- Tracks daily closure per admin.
- Calculates:
  - Opening Balance (till yesterday)
  - Today’s Collection
  - Payment Made
  - Closing Outstanding


### 🔐 Role-Based Access Control (RBAC)
- Enforced admin-only access to:
  - `/admin/lots`
  - `/admin/closure`
- JWT tokens are decoded to check the user’s role (`admin` vs `user`).
- If a non-admin attempts access, the system returns **403 Forbidden**.


### 📈 Daily Closure API
- Admins submit daily collection summary with optional partial payoff.
- Response shows new outstanding amount.

---

## 🧱 Database Schema Additions

### Table: `admin_parking_lots`
| Column         | Type    | Description                   |
|----------------|---------|-------------------------------|
| id             | Integer | Primary Key                   |
| admin_id       | Integer | FK → users.id                 |
| parking_lot_id | Integer | FK → parking_lot_details.id   |

### Table: `parking_sessions`
| Column         | Type      | Description                   |
|----------------|-----------|-------------------------------|
| id             | Integer   | Primary Key                   |
| vehicle_reg_no | String    | Vehicle number                |
| vehicle_type   | String    | "Car" or "Two-Wheeler"        |
| slot_id        | Integer   | FK → slot.id                  |
| lot_id         | Integer   | FK → parking_lot_details.id   |
| check_in_time  | DateTime  | Auto now                      |
| check_out_time | DateTime  | Nullable                      |
| amount_paid    | Float     | Nullable                      |
| Column        | Type      | Description                   |
|---------------|-----------|-------------------------------|
| id            | Integer   | Primary Key                   |
| vehicle_reg_no| String    | Vehicle number                |
| slot_id       | Integer   | FK → slot.id                  |
| lot_id        | Integer   | FK → parking_lot_details.id   |
| check_in_time | DateTime  | Auto now                      |
| check_out_time| DateTime  | Nullable                      |
| amount_paid   | Float     | Nullable                      |

### Table: `admin_payment_ledger`
| Column          | Type     | Description                    |
|-----------------|----------|--------------------------------|
| id              | Integer  | Primary Key                    |
| admin_id        | Integer  | FK → users.id                  |
| date            | Date     | Daily entry                    |
| opening_balance | Float    | Outstanding from prev days     |
| today_collection| Float    | Today’s collected amount       |
| payment_made    | Float    | What admin paid today          |
| closing_balance | Float    | Final outstanding amount       |

---

## 📌 Summary

| Feature                       | Version |
|------------------------------|---------|
| Realtime Slot Tracking       | 1.0     |
| Hierarchical Lot Structure   | 1.0     |
| Admin Role & Lot Mapping     | 2.0     |
| Vehicle Entry/Exit Sessions  | 2.0     |
| Daily Closure Ledger         | 2.0     |

---

End of Document.
