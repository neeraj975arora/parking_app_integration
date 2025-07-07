# Product Requirements Document (PRD)

## Title: Parking Detection System — Initialization and Status Update Automation

### Author: Shubham Goyal  
### Version: 1.0  
### Last Updated: 2025-06-25

---

## 1. Objective

Enhance the existing YOLO + OpenCV-based parking detection system by:
- Creating a dummy parking lot in the database.
- Populating that parking lot with slot data from a `parking_spots.json` file (one-time operation).
- Periodically analyzing a live video feed to detect occupancy status of each slot using a trained ML model.
- Updating the slot statuses and recalculating the total available slots using backend APIs.

---

## 2. Background

A YOLO + OpenCV-based system is already trained and deployed to detect whether parking slots are occupied. Cloud-hosted API endpoints exist for managing parking lot data. Currently, the system lacks functionality for:
- Initializing parking lots and slots.
- Dynamically updating slot statuses based on real-time video input.
- Updating available slot count in the database automatically.

---

## 3. Scope

This PRD includes:
- Creating and storing parking lot data.
- Parsing `parking_spots.json` to populate individual slots into the database.
- Integrating video feed analysis with periodic ML-based slot detection.
- Updating the slot status and total available slots via APIs.

---

## 4. Features

### 4.1 One-Time Dummy Parking Lot Initialization

**Description:**  
Insert a new parking lot into the `parkinglots_details` table using dummy data.

**Schema Used:**
```python
class ParkingLotDetails(db.Model):
    __tablename__ = 'parkinglots_details'
    id = db.Column('parkinglot_id', db.Integer, primary_key=True)
    name = db.Column('parking_name', db.String(255), nullable=False)
    address = db.Column(db.String(255), nullable=False)
    zip_code = db.Column(db.String(10), nullable=False)
    city = db.Column(db.String(50), nullable=False)
    state = db.Column(db.String(50), nullable=False)
    country = db.Column(db.String(50), nullable=False)
    phone_number = db.Column(db.String(15), nullable=False)
    opening_time = db.Column(db.Time)
    closing_time = db.Column(db.Time)
    total_floors = db.Column(db.Integer)
    total_rows = db.Column(db.Integer)
    total_slots = db.Column(db.Integer)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


    floors = db.relationship('Floor', backref='parking_lot', lazy=True)



```

**Fields to Include:**
- Name: `"Central Mall Lot"`
- Address: `"123 Main Street"`
- Zip Code: `"123456"`
- City: `"Sample City"`
- State: `"Sample State"`
- Country: `"Sample Country"`
- Phone Number: `"9998887777"`
- Opening/Closing Times: `"08:00"` to `"22:00"`
- Total Floors: `2`
- Total Rows: `4`
- Total Slots: Derived from `slots.json`

---

### 4.2 Add Slots Using `parking_spots.json`

**Description:**  
Once the parking lot is created, read a `parking_spots.json` file and populate the `slots` table with relevant data, linking each slot to the newly created parking lot.

**Expected JSON Structure:**
```json
[
  {
    "name": "A1",
    "status": 0,
    "row_id": 1,
    "floor_id": 1
  },
  ...
]
```

**Database Schema Used:**
```python
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


    sessions = db.relationship('ParkingSession', backref='slot', lazy=True)

```

---

### 4.3 Periodic Slot Status Update via ML Video Analysis

**Description:**  
Use the trained YOLO + OpenCV model to analyze a video feed at regular intervals and determine if each parking slot is occupied or not.

**Process:**
1. Feed video to ML model.
2. Get real-time slot occupancy prediction.
3. Map detected slots to DB entries (using name or ID).
4. Update `status` field in the `slots` table.

**Tools:**
- Background Scheduler: APScheduler / Celery
- ML Inference API: Custom endpoint using OpenCV + YOLO
- Frequency: Every 5 minutes

**Sample ML Output:**
```json
[
  { "name": "A1", "status": 1 },
  { "name": "A2", "status": 0 }
]
```

---

### 4.4 Update Slot Availability status in database

**Description:**  
Update the availability status of all the slots analyzed.

**Logic:**
```python
available = Slot.query.filter_by(parkinglot_id=lot_id, status=0).count()
lot = ParkingLotDetails.query.get(lot_id)
lot.total_slots = available
db.session.commit()
```

---

## 5. Non-Functional Requirements

| Requirement        | Description |
|--------------------|-------------|
| Performance        | Slot update and recalculation must complete within 5 seconds |
| Scalability        | Must support multiple parking lots in the future |
| Reliability        | System must not crash if ML API is unreachable |
| Maintainability    | Code must be modular, readable, and tested |
| Security           | APIs must be protected with authentication and rate-limiting if exposed |

---

## 6. Deliverables

- One-time script to create a dummy parking lot and populate slots from `slots.json`
- Background job to:
  - Analyze video via ML model
  - Update each slot’s `status`
  - Update total available slots in the lot
- Sample `slots.json` file
- API interface to trigger updates (optional)

---

## 7. Out of Scope

- User authentication or role-based access
- Web frontend UI for parking visualization
- Real-time updates via WebSockets
- Billing or ticket generation

---

## 8. Risks

| Risk | Mitigation |
|------|------------|
| Duplicate slot names | Enforce uniqueness using DB constraints |
| ML model inaccuracies | Add threshold filtering and allow manual override |
| Video feed failures | Add error handling and retry logic |

---

## 9. Appendix

### 9.1 Entity Relationships (Simplified)

- **ParkingLotDetails** has many **Floors**
- **Floors** have many **Rows**
- **Rows** have many **Slots**
- **Slots** are periodically updated via ML model

### 9.2 Suggested Table Constraint

```python
__table_args__ = (
    db.UniqueConstraint('slot_name', 'parkinglot_id', name='unique_slot_per_lot'),
)
```
