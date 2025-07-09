# Smart Parking Cloud Server – Version 2.0 Task Breakdown

**This document details the implementation tasks for Version 2.0 features as described in the PRD.**

---

## 1. Admin Role Management
- [x] Add `role` field to `users` table (`user`, `admin`).
- [x] Update user registration and management logic to support roles.
- [x] Implement admin assignment to one or more parking lots.
- [x] Update authentication logic to include role in JWT claims.
- [x] Test role assignment and JWT payloads.

## 2. Admin-to-Lot Mapping
- [x] Create `admin_parking_lots` table (admin_id, parking_lot_id).
- [x] Add SQLAlchemy model and migration for `admin_parking_lots`.
- [x] Implement CRUD endpoints for admin-lot mapping.
- [x] Add validation to ensure only admins can be mapped.
- [x] Write tests for mapping logic and endpoints.

## 3. Vehicle Check-In API
- [x] Design and implement API endpoint to start a new `ParkingSession`.
- [x] Capture check-in time, vehicle details, and slot/lot info.
- [x] Validate slot availability before check-in.
- [x] Add tests for check-in flow and edge cases.

## 4. Vehicle Check-Out API
- [x] Design and implement API endpoint to end a `ParkingSession`.
- [x] Calculate amount due based on lot’s hourly rate and vehicle type.
- [x] Store payment amount and check-out timestamp.
- [x] Mark slot as available after check-out.
- [x] Add tests for check-out flow and billing logic.

## 5. Vehicle Type Support for Billing
- [x] Add `vehicle_type` field to `ParkingSession` model and migration.
- [x] Update check-in/check-out APIs to handle vehicle type.
- [x] Implement rate differentiation for `Car` and `Two-Wheeler`.
- [x] Test billing for both vehicle types.

## 6. Admin Payment Ledger
- [x] Create `admin_payment_ledger` table (see PRD for fields).
- [x] Add SQLAlchemy model and migration for ledger.
- [x] Implement logic to calculate opening balance, today’s collection, payment made, closing balance.
- [x] Create endpoints for ledger retrieval and update.
- [x] Add tests for ledger calculations and API.

## 7. Role-Based Access Control (RBAC)
- [x] Enforce admin-only access to `/admin/lots` and `/admin/closure` endpoints.
- [x] Decode JWT tokens and check user’s role in protected endpoints.
- [x] Return 403 Forbidden for unauthorized access.
- [x] Add tests for RBAC enforcement.

## 8. Daily Closure API
- [x] Design and implement API for admins to submit daily collection summary.
- [x] Support optional partial payoff in request.
- [x] Response should show new outstanding amount.
- [x] Add tests for daily closure logic and edge cases.

## 9. Database Schema Updates
- [x] Update models and create migrations for:
    - [x] `admin_parking_lots`
    - [x] `parking_sessions` (add `vehicle_type`)
    - [x] `admin_payment_ledger`
    - [x] `users` (add `role` field)
- [x] Test all migrations and schema changes.

## 10. Documentation & Testing
- [ ] Update API documentation (Swagger/OpenAPI) for new/changed endpoints.
- [ ] Write unit and integration tests for all new features.
- [ ] Add usage examples for new endpoints in API docs.

---

**End of Version 2.0 Task Breakdown** 