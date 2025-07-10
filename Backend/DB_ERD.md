# Entity-Relationship Diagram (ERD)

> **Tip:** To view the ERD diagram below, use a Markdown preview extension that supports Mermaid diagrams (such as "Markdown Preview Mermaid Support" for VS Code, or enable Mermaid in your preferred Markdown viewer).

This diagram represents the relationships between tables in the Smart Parking backend database.

```mermaid
erDiagram
    User {
        int user_id PK
        string user_name
        string user_email
        string user_password
        string user_phone_no
        text user_address
        string role
    }
    ParkingLotDetails {
        int parkinglot_id PK
        text parking_name
        text city
        text landmark
        text address
        numeric latitude
        numeric longitude
        text physical_appearance
        text parking_ownership
        text parking_surface
        text has_cctv
        text has_boom_barrier
        text ticket_generated
        text entry_exit_gates
        text weekly_off
        text parking_timing
        text vehicle_types
        int car_capacity
        int available_car_slots
        int two_wheeler_capacity
        int available_two_wheeler_slots
        text parking_type
        text payment_modes
        text car_parking_charge
        text two_wheeler_parking_charge
        text allows_prepaid_passes
        text provides_valet_services
        text value_added_services
    }
    Floor {
        int floor_id PK
        string floor_name
        int parkinglot_id FK
    }
    Row {
        int row_id PK
        string row_name
        int floor_id FK
        int parkinglot_id
    }
    Slot {
        int slot_id PK
        string slot_name
        int status
        string vehicle_reg_no
        string ticket_id
        int row_id FK
        int floor_id
        int parkinglot_id
    }
    ParkingSession {
        string ticket_id PK
        int parkinglot_id
        int floor_id
        int row_id
        int slot_id FK
        string vehicle_reg_no
        int user_id FK
        datetime start_time
        datetime end_time
        numeric duration_hrs
        string vehicle_type
    }
    AdminParkingLot {
        int id PK
        int admin_id FK
        int parking_lot_id FK
    }
    AdminPaymentLedger {
        int id PK
        int admin_id FK
        date date
        float opening_balance
        float today_collection
        float payment_made
        float closing_balance
    }

    User ||--o{ ParkingSession : "has"
    User ||--o{ AdminPaymentLedger : "has"
    ParkingLotDetails ||--o{ Floor : "has"
    Floor ||--o{ Row : "has"
    Row ||--o{ Slot : "has"
    Slot ||--o{ ParkingSession : "used in"
    User ||--o{ AdminParkingLot : "admin of"
    ParkingLotDetails ||--o{ AdminParkingLot : "assigned to"
    User ||--o{ AdminPaymentLedger : "ledger for"
    ParkingLotDetails ||--o{ AdminParkingLot : "lot for admin"
``` 