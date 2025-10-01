## Admin Endpoints (`/admin`)

### Admin-to-Lot Assignment (Super Admin Only)

| Method                                     | Path                                  | Description                                               | Protected (Role)  | usage                                                                                   |
| ------------------------------------------ | ------------------------------------- | --------------------------------------------------------- | ----------------- | --------------------------------------------------------------------------------------- |
| POST                                       | /admin/assign_lot                     | Assign a parking lot to an admin                          | Yes (super_admin) | when "create admin" button on "admin management screen" is pressed                               |
| DELETE                                     | /admin/remove_assignment              | Remove admin-lot assignment                               | Yes (super_admin) | when "delete" button on "admin management screen" is pressed                                     |
| GET                                       | /admin/admin_lots/all    | Get all parking lot details assigned to different admins   | Yes(Super_admin) | super admin to retrieve a list of all parking lot details to populate "existing Admin section" of "admin management screen" when it is initially loaded that are assigned to each individual admin | to populate "admin management screen" |
| GET                                        | /admin/sessions/details/all          | Get all parking sessions details for all last 3 months     | Yes (super admin) | to populate "live sessions screen" for super admin" or to populate "payment collections screen" or to populate "dashboard screen" after successful login as superadmin.|





### Example Request Body for /admin/assign_lot

```json
{
  "name": "Jane Smith",
  "email": "jane.smith@example.com",
  "password": "securePassword123",
  "address": "Impressico",
  "phone_no": "9876543210"
  "assigned_lots": [1, 3],
  "role": "admin"  // Role input will not be taken from UI but it'll be hardcoded in request from frontend as API requires this field 
}
```

### example response Status: 201 Created

```json
{
  "message": "Admin created successfully",
  "user_id": 42,
  "role": "admin"
  "assigned_lots": [1, 3]
}
```

### Failure Cases - 1. Missing Fields Status: 400 Bad Request

```json
{
  "error": "Name, email, password, and assigned_lots are required."
}
```

### 2. Invalid Assigned Lots Format Status: 400 Bad Request

```json
{
  "error": "assigned_lots must be a non-empty array of parking lot IDs."
}
```

### 3. Duplicate Email Status: 409 Conflict

```json
{
  "error": "An admin with this email already exists."
}
```

#### 4. Assigned Lot Does Not Exist Status: 400 Bad Request

```json
{
  "error": "One or more assigned parking lot IDs do not exist."
}
```

#### 5. Unauthorized (non-super-admin) Status: 403 Forbidden

```json
{
  "error": "You are not authorized to create admin accounts."
}
```

### sample reply for GET /admin/admin_lots/all JSON object containing a list of objects. Each object represents an admin and the parking lot IDs assigned to them.

```json
{
  "meta": {
    "total": 2
  },

  "data": [
    {
      "user_id": 1,
      "user_name": "Admin1",
      "user_email": "admin1@company.com",
      "user_phone_no": "7449430680",
      "user_address": "abcd efgh",
      "joining_date": "2024-10-30T16:19:36.921Z",
      "status": "active",
      "assigned_lots": [
        {
          "parkinglot_id": 3,
          "parking_name": "Central Plaza Parking",
          "location": {
            "address": "Powai, Mumbai",
            "landmark": "Near Police Station",
            "coordinates": {
              "latitude": 19.304522,
              "longitude": 73.288747
            }
          },
          "parking_type": "commercial",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        },
        {
          "parkinglot_id": 18,
          "parking_name": "Shopping Mall Complex West",
          "location": {
            "address": "Sector 62",
            "city": "Pune",
            "state": "Maharashtra",
            "pincode": "338515",
            "landmark": "Adjacent to Restaurant",
            "coordinates": {
              "latitude": 18.550737,
              "longitude": 73.951299
            },
            "area_type": "industrial"
          },
          "parking_type": "shopping_mall",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        }
      ],
      "permissions": [
        "*"
      ],
      "shift_timings": {
        "start_time": "10:00",
        "end_time": "18:00",
        "shift_name": "Regular Shift",
        "days": [
          "monday",
          "tuesday",
          "wednesday",
          "thursday",
          "friday",
          "saturday"
        ]
      }
    },
    {
      "user_id": 2,
      "user_name": "Admin2",
      "user_email": "admin2@company.com",
      "user_phone_no": "7449430696",
      "user_address": "abcd efgh",
      "joining_date": "2024-10-30T16:19:36.921Z",
      "status": "active",
      "assigned_lots": [
        {
          "parkinglot_id": 5,
          "parking_name": "Central Plaza Parking",
          "location": {
            "address": "Powai, Mumbai",
            "landmark": "Near Police Station",
            "coordinates": {
              "latitude": 19.304522,
              "longitude": 73.288747
            }
          },
          "parking_type": "commercial",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        },
        {
          "parkinglot_id": 15,
          "parking_name": "Shopping Mall Complex West",
          "location": {
            "address": "Sector 62",
            "city": "Pune",
            "state": "Maharashtra",
            "pincode": "338515",
            "landmark": "Adjacent to Restaurant",
            "coordinates": {
              "latitude": 18.550737,
              "longitude": 73.951299
            },
            "area_type": "industrial"
          },
          "parking_type": "shopping_mall",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        }
      ],
      // These fields are for future use 
      // "permissions": [
      //   "*"
      // ],
      // "shift_timings": {
      //   "start_time": "10:00",
      //   "end_time": "18:00",
      //   "shift_name": "Regular Shift",
      //   "days": [
      //     "monday",
      //     "tuesday",
      //     "wednesday",
      //     "thursday",
      //     "friday",
      //     "saturday"
      //   ]
      // }
    }
  ]
}
```  


### GET /admin/sessions/details/all - fetch complete sessions table - covering parking_lots of all admin (see per parking_lot api in admin section)

```json
 [
  {
    "ticket_id": "TKT-987654",
    "parkinglot_id": 123,
    "vehicle_reg_no": "DL2S 223",
    "user_id": 123,
    "start_time": "2025-07-31T18:30:00Z",
    "end_time": "2025-07-31T20:30:00Z",
    "duration_hrs": 2.0,
    "vehicle_type": "car"
  },
  {
    "ticket_id": "TKT-543210",
    "parkinglot_id": 456,
    "vehicle_reg_no": "KA01 AB 1234",
    "user_id": 456,
    "start_time": "2025-07-31T17:00:00Z",
    "end_time": "2025-07-31T18:00:00Z",
    "duration_hrs": 1.0,
    "vehicle_type": "motorcycle"
  },
  {
    "ticket_id": "TKT-112233",
    "parkinglot_id": 123,
    "vehicle_reg_no": "MH12 CD 5678",
    "user_id": 789,
    "start_time": "2025-07-31T19:00:00Z",
    "end_time": null,
    "duration_hrs": null,
    "vehicle_type": "car"
  },
  {
    "ticket_id": "TKT-654321",
    "parkinglot_id": 789,
    "vehicle_reg_no": "DL5S 7788",
    "user_id": 123,
    "start_time": "2025-07-30T10:00:00Z",
    "end_time": "2025-07-30T11:00:00Z",
    "duration_hrs": 1.0,
    "vehicle_type": "car"
  },
  {
    "ticket_id": "TKT-009988",
    "parkinglot_id": 456,
    "vehicle_reg_no": "HR26 XX 9090",
    "user_id": 101,
    "start_time": "2025-07-30T14:15:00Z",
    "end_time": "2025-07-30T15:30:00Z",
    "duration_hrs": 1.25,
    "vehicle_type": "motorcycle"
  }
]
```

### APIs admin role Admin Lot & Session Management (Admin Only)

| Method | Path                             | Description                                    | Protected (Role) | usage                                                                                           |
| ------ | -------------------------------- | ---------------------------------------------- | ---------------- | ----------------------------------------------------------------------------------------------- |
| GET    | /admin/admin_lots/<user_id>            | Get all lot IDs assigned to an admin           | Yes (admin)      |    Used to get data for "System Information" Card on Dashboard Page|
| POST   | /admin/session/checkin           | Admin check-in for a vehicle                   | Yes (admin)      | Not currently in use |
| POST   | /admin/session/checkout          | Admin check-out for a vehicle                  | Yes (admin)      | live "session screen","x" button to checkout                                                      |
| POST   | /admin/closure                   | Submit daily closure/payment                   | Yes (admin)      | on "daily closure screen" when "finalize closure" button is pressed                                      |
| GET    | /admin/closure                   | Get closure ledger entries                     | Yes (admin)      | to populate "daily closure screen"                                                                 |
| GET    | /admin/sessions/details/<user_id> | Get all parking session details for this admin | Yes (admin)      | to populate "dashboard screen" after successful login as admin with user as <userid> or to populate "live sessions screen" or "payment collection" for given admin with id as <user_id>. |
| GET    | /admin/total_due | Get total due information               | Yes (admin) |  To retrieve outstanding and today's collection at the start of the closure process.|
| POST   | /admin/finalize_closure | Get  finalize closure for payment      |Yes (admin) | Admin submits the amount he/she is settling with. |



## Example Json for GET /admin/admin_lots/{user_id}

Purpose: To check and retrieve the parking lots assigned to an particular admin.

#### Response
```json
{
      "user_id": 1,
      "user_name": "Admin1",
      "user_email": "admin1@company.com",
      "user_phone_no": "7449430680",
      "user_address": "abcd efgh",
      "joining_date": "2024-10-30T16:19:36.921Z",
      "status": "active",
      "assigned_lots": [
        {
          "parkinglot_id": 3,
          "parking_name": "Central Plaza Parking",
          "location": {
            "address": "Powai, Mumbai",
            "landmark": "Near Police Station",
            "coordinates": {
              "latitude": 19.304522,
              "longitude": 73.288747
            }
          },
          "parking_type": "commercial",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        },
        {
          "parkinglot_id": 18,
          "parking_name": "Shopping Mall Complex West",
          "location": {
            "address": "Sector 62",
            "city": "Pune",
            "state": "Maharashtra",
            "pincode": "338515",
            "landmark": "Adjacent to Restaurant",
            "coordinates": {
              "latitude": 18.550737,
              "longitude": 73.951299
            },
            "area_type": "industrial"
          },
          "parking_type": "shopping_mall",
          "assigned_date": "2025-09-19T13:47:26.833Z"
        }
      ],
      // These fields are for future use 
      // "permissions": [                      
      //   "*"
      // ],
      // "shift_timings": {                   
      //   "start_time": "10:00",
      //   "end_time": "18:00",
      //   "shift_name": "Regular Shift",
      //   "days": [
      //     "monday",
      //     "tuesday",
      //     "wednesday",
      //     "thursday",
      //     "friday",
      //     "saturday"
      //   ]
      // }
    }
```

## Example GET /admin/sessions/details/<user_id>


#### Request
```json
{
    "user_id":123,   //user_id 123 is of user with role "admin"
    "time in months":3  //applied in API logic
}
```

#### Response
```json
[
  {
    "ticket_id": "TKT-987654",
    "parkinglot_id": 123,
    "vehicle_reg_no": "DL2S 223",
    "user_id": 133,
    "start_time": "2025-07-31T18:30:00Z",
    "end_time": "2025-07-31T20:30:00Z",
    "duration_hrs": 2.0,
    "vehicle_type": "car"
  },
  {
    "ticket_id": "TKT-543210",
    "parkinglot_id": 456,
    "vehicle_reg_no": "KA01 AB 1234",
    "user_id": 456,
    "start_time": "2025-07-31T17:00:00Z",
    "end_time": "2025-07-31T18:00:00Z",
    "duration_hrs": 1.0,
    "vehicle_type": "motorcycle"
  },
  {
    "ticket_id": "TKT-112233",
    "parkinglot_id": 123,
    "vehicle_reg_no": "MH12 CD 5678",
    "user_id": 789,
    "start_time": "2025-07-31T19:00:00Z",
    "end_time": null,
    "duration_hrs": null,
    "vehicle_type": "car"
  }
]
Reply should include all fields from sessions table   
```

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

#### RESTful flow suggestion for your admin daily closure operation

1. GET /admin/total_due


   Purpose: To retrieve outstanding and today's collection at the start of the closure process.

Response Format:

```json
{
  "date": "2025-07-04",
  "outstanding_amount": 5450.75,
  "today_collection": 3210.50
}
```

2. POST /admin/finalize_closure
Purpose: Admin submits the amount he/she is settling with.

```json

Request
{
  "payment_made": 7980
}

Response
{
  "new_outstanding": 681.25
}
```

#### Example JSON for POST /admin/closure 

```json

Request 
{
  "date": "2025-07-04",
  "payment_made": 500.0
}


Response
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
