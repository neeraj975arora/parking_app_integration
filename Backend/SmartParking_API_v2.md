# API Endpoints – Smart Parking Cloud Server (v2.0)
# 🛡️ Only users with `role: admin` can access these endpoints. Others will receive a 403 Forbidden response.


## 🚗 Vehicle Session Management

### Vehicle Check-In
**POST** `/admin/session/checkin`  
Headers: `Authorization: Bearer <JWT>`

```json
{
  "vehicle_reg_no": "DL01AB1234",
  "slot_id": 12,
  "lot_id": 3,
  "vehicle_type": "Car"
}
```

**Response:**
```json
{
  "msg": "Vehicle checked in",
  "session_id": "<uuid>"
}
```

---

### Vehicle Check-Out
**POST** `/admin/session/checkout`  
Headers: `Authorization: Bearer <JWT>`

```json
{
  "vehicle_reg_no": "DL01AB1234"
}
```

**Response:**  
```json
{
  "amount_paid": 40.0,
  "duration_hours": 2,
  "checkout_time": "2025-07-04T13:10:00Z"
}
```

---

## 👨‍💼 Admin APIs

### Get Parking Lots for Admin
**GET** `/admin_lots/<admin_id>`  
Headers: `Authorization: Bearer <JWT>`

**Response:**  
```json
{
  "admin_id": 1,
  "parking_lot_ids": [1, 2, 3]
}
```

---

### Daily Closure & Outstanding Payment
**POST** `/admin/closure`  
Headers: `Authorization: Bearer <JWT>`

```json
{
  "date": "2025-07-04",
  "payment_made": 500.0
}
```

**Response:**  
```json
{
  "opening_balance": 1000.0,
  "today_collection": 800.0,
  "payment_made": 500.0,
  "closing_balance": 1300.0
}
```

---

**Note:**
- Endpoint paths and response formats above reflect the actual implementation. Some paths and response fields differ from the original spec for clarity and backend alignment.

End of API Document.
