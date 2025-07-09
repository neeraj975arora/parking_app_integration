## Admin Endpoints (`/admin`)

### Admin-to-Lot Assignment (Super Admin Only)
| Method | Path                | Description                        | Protected (Role)   |
|--------|---------------------|------------------------------------|--------------------|
| POST   | /admin/assign_lot   | Assign a parking lot to an admin   | Yes (super_admin)  |
| DELETE | /admin/remove_assignment | Remove admin-lot assignment     | Yes (super_admin)  |

### Admin Lot & Session Management
| Method | Path                              | Description                                 | Protected (Role) |
|--------|-----------------------------------|---------------------------------------------|------------------|
| GET    | /admin_lots/<admin_id>            | Get all lot IDs assigned to an admin        | Yes (admin)      |
| POST   | /admin/session/checkin            | Admin check-in for a vehicle                | Yes (admin)      |
| POST   | /admin/session/checkout           | Admin check-out for a vehicle               | Yes (admin)      |
| POST   | /admin/closure                    | Submit daily closure/payment                | Yes (admin)      |
| GET    | /admin/closure                    | Get closure ledger entries                  | Yes (admin)      |

#### Example JSON for /admin/session/checkin
```json
{
  "vehicle_reg_no": "DL01AB1234",
  "slot_id": 12,
  "lot_id": 3,
  "vehicle_type": "Car"
}
```

#### Example JSON for /admin/session/checkout
```json
{
  "vehicle_reg_no": "DL01AB1234"
}
```

#### Example JSON for /admin/closure (POST)
```json
{
  "date": "2025-07-04",
  "payment_made": 500.0
}
```

#### Example JSON for /admin/closure (Response)
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
- `Protected: Yes (user/admin)` means the endpoint requires a valid JWT access token for a user with role `user` or `admin`.
- `Protected: Yes (admin)` means the endpoint requires a valid JWT access token for a user with role `admin`.
- `Protected: Yes (super_admin)` means the endpoint requires a valid JWT access token for a user with role `super_admin`.
- `Protected: API Key` means the endpoint requires a valid API key in the `X-API-KEY` header.
- `Protected: No` means the endpoint is public and does not require authentication.
- Most endpoints (except `/auth` and `/api/v1/slots/update_status`) require JWT authentication in the `Authorization` header.
- Admin endpoints enforce strict role-based access control (RBAC) as per the backend implementation. 