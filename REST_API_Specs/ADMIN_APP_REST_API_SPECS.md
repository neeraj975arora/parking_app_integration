## Admin Endpoints (`/admin`)

### Admin-to-Lot Assignment (Super Admin Only)
| Method | Path                | Description                        | Protected (Role)   |
|--------|---------------------|------------------------------------|--------------------|
| POST   | /admin/assign_lot   | Assign a parking lot to an admin   | Yes (super_admin)  |
| DELETE | /admin/remove_assignment | Remove admin-lot assignment     | Yes (super_admin)  |
| POST   | /admin/register_admin | Register a new admin (super_admin only) | Yes (super_admin) |

### Admin Lot & Session Management
| Method | Path                              | Description                                 | Protected (Role) |
|--------|-----------------------------------|---------------------------------------------|------------------|
| GET    | /admin_lots/<admin_id>            | Get all lot IDs assigned to an admin        | Yes (admin)      |
| POST   | /admin/session/checkin            | Admin check-in for a vehicle                | Yes (admin)      |
| POST   | /admin/session/checkout           | Admin check-out for a vehicle               | Yes (admin)      |
| POST   | /admin/closure                    | Submit daily closure/payment                | Yes (admin)      |
| GET    | /admin/closure                    | Get closure ledger entries                  | Yes (admin)      |

#### Example JSON for /auth/login (Response)
```json
{
  "access_token": "<JWT_TOKEN>",
  "username": "adminuser",
  "user_email": "admin@example.com",
  "user_id": 2,
  "user_address": "HQ",
  "user_phone_no": "9876543210",
  "role": "admin"
}
```
*Note: The `access_token` (JWT) is returned in all login responses. This token must be included in the `Authorization` header for all protected endpoints. The role is embedded in the token and should be used to determine access rights.*

#### Example JSON for /admin/register_admin
```json
{
  "user_name": "Admin User",
  "user_email": "admin@example.com",
  "user_password": "adminpass",
  "user_phone_no": "9876543210",
  "user_address": "HQ"
}
```

#### Example request for /admin/register_admin

```
POST /admin/register_admin
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "user_name": "Admin User",
  "user_email": "admin@example.com",
  "user_password": "adminpass",
  "user_phone_no": "9876543210",
  "user_address": "HQ"
}
```

#### Example response for /admin/register_admin
```json
{
  "msg": "Admin registered successfully",
  "role": "admin"
}
```

*Note: The `<access_token>` must be obtained from the `/auth/login` endpoint and included in the `Authorization` header for all protected endpoints.*

#### Example request for /admin/assign_lot
```
POST /admin/assign_lot
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "admin_id": 2,
  "parking_lot_id": 3
}
```
#### Example response for /admin/assign_lot
```json
{
  "msg": "Parking lot assigned to admin"
}
```

#### Example request for /admin/remove_assignment
```
DELETE /admin/remove_assignment
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "admin_id": 2,
  "parking_lot_id": 3
}
```
#### Example response for /admin/remove_assignment
```json
{
  "msg": "Assignment removed"
}
```

#### Example request for /admin_lots/<admin_id>
```
GET /admin_lots/2
Authorization: Bearer <access_token>
```
#### Example response for /admin_lots/<admin_id>
```json
{
  "admin_id": 2,
  "parking_lot_ids": [3, 4]
}
```

#### Example request for /lot_admins/<lot_id>
```
GET /lot_admins/3
Authorization: Bearer <access_token>
```
#### Example response for /lot_admins/<lot_id>
```json
{
  "parking_lot_id": 3,
  "admin_ids": [2]
}
```

#### Example request for /admin/session/checkin
```
POST /admin/session/checkin
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "vehicle_reg_no": "DL01AB1234",
  "slot_id": 12,
  "lot_id": 3,
  "vehicle_type": "Car"
}
```
#### Example response for /admin/session/checkin
```json
{
  "msg": "Vehicle checked in",
  "session_id": "b1e2c3d4-5678-90ab-cdef-1234567890ab"
}
```

#### Example request for /admin/session/checkout
```
POST /admin/session/checkout
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "vehicle_reg_no": "DL01AB1234"
}
```
#### Example response for /admin/session/checkout
```json
{
  "amount_paid": 80.0,
  "duration_hours": 2,
  "checkout_time": "2025-07-10T15:30:00Z"
}
```

#### Example request for /admin/closure (POST)
```
POST /admin/closure
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "date": "2025-07-04",
  "payment_made": 500.0
}
```
#### Example response for /admin/closure (POST)
```json
{
  "opening_balance": 1000.0,
  "today_collection": 800.0,
  "payment_made": 500.0,
  "closing_balance": 1300.0
}
```

#### Example request for /admin/closure (GET)
```
GET /admin/closure?start_date=2025-07-01&end_date=2025-07-10
Authorization: Bearer <access_token>
```
#### Example response for /admin/closure (GET)
```json
[
  {
    "date": "2025-07-04",
    "opening_balance": 1000.0,
    "today_collection": 800.0,
    "payment_made": 500.0,
    "closing_balance": 1300.0
  },
  {
    "date": "2025-07-05",
    "opening_balance": 1300.0,
    "today_collection": 600.0,
    "payment_made": 400.0,
    "closing_balance": 1500.0
  }
]
```

*Note: The `<access_token>` must be obtained from the `/auth/login` endpoint and included in the `Authorization` header for all protected endpoints.*
