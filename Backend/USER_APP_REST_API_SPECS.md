# API Endpoints Documentation

## API Key Authentication (For IoT/Device Endpoints)

Some endpoints (such as those used by IoT devices) require an API key for authentication instead of a user login/JWT.

- **Default API Key:** If not set in your environment, the default API key is:
  ```
  super-secret-rpi-key
  ```
- **How to set your own:**
  - In your `.env` file, add or change:
    ```
    RPI_API_KEY=your_custom_api_key_here
    ```
- **How to use:**
  - When making a request to an API key-protected endpoint, include this header:
    ```
    X-API-KEY: your_api_key_here
    ```
  - Example using the default:
    ```
    X-API-KEY: super-secret-rpi-key
    ```
- **If the key is missing or incorrect, the server will respond with 401 Unauthorized.**

---

## Authentication Endpoints (`/auth`)

| Method | Path           | Description                | Protected |
| ------ | -------------- | -------------------------- | --------- |
| POST   | /auth/register | Register a new user        | No        |
| POST   | /auth/login    | User login (get JWT token) | No        |

### Example JSON for /auth/register

```json
{
  "user_name": "John Doe",
  "user_email": "john@example.com",
  "user_password": "password123",
  "user_phone_no": "1234567890",
  "user_address": "123 Main St"
}
```

### Example JSON for /auth/login

```json
{
  "user_email": "john@example.com",
  "user_password": "password123"
}
```

## Parking Management Endpoints (`/parking`)

### Parking Lot

| Method | Path                           | Description                                  | Protected (Role) |
| ------ | ------------------------------ | -------------------------------------------- | ---------------- |
| POST   | /parking/lots                  | Create a new parking lot                     | Yes (user/admin) |
| GET    | /parking/lots                  | Get all parking lots (summary)               | Yes (user/admin) |
| GET    | /parking/lots/\<lot\_id>       | Get details of a specific parking lot        | Yes (user/admin) |
| PUT    | /parking/lots/\<lot\_id>       | Update a parking lot                         | Yes (user/admin) |
| DELETE | /parking/lots/\<lot\_id>       | Delete a parking lot                         | Yes (user/admin) |
| GET    | /parking/lots/\<lot\_id>/stats | Get stats (total, occupied, available slots) | Yes (user/admin) |

#### Example JSON for /parking/lots (POST/PUT)

```json
{
  "name": "Lot A",
  "address": "123 Main St",
  "description": "Main parking lot"
}
```

### Floor

| Method | Path                            | Description                         | Protected (Role) |
| ------ | ------------------------------- | ----------------------------------- | ---------------- |
| POST   | /parking/lots/\<lot\_id>/floors | Create a new floor in a parking lot | Yes (user/admin) |
| GET    | /parking/lots/\<lot\_id>/floors | Get all floors for a parking lot    | Yes (user/admin) |
| GET    | /parking/floors/\<floor\_id>    | Get details of a specific floor     | Yes (user/admin) |
| PUT    | /parking/floors/\<floor\_id>    | Update a floor                      | Yes (user/admin) |
| DELETE | /parking/floors/\<floor\_id>    | Delete a floor                      | Yes (user/admin) |

#### Example JSON for /parking/lots/\<lot\_id>/floors (POST/PUT)

```json
{
  "floor_number": 1,
  "description": "First floor"
}
```

### Row

| Method | Path                              | Description                   | Protected (Role) |
| ------ | --------------------------------- | ----------------------------- | ---------------- |
| POST   | /parking/floors/\<floor\_id>/rows | Create a new row in a floor   | Yes (user/admin) |
| GET    | /parking/floors/\<floor\_id>/rows | Get all rows for a floor      | Yes (user/admin) |
| GET    | /parking/rows/\<row\_id>          | Get details of a specific row | Yes (user/admin) |
| PUT    | /parking/rows/\<row\_id>          | Update a row                  | Yes (user/admin) |
| DELETE | /parking/rows/\<row\_id>          | Delete a row                  | Yes (user/admin) |

#### Example JSON for /parking/floors/\<floor\_id>/rows (POST/PUT)

```json
{
  "row_name": "A",
  "description": "Row A"
}
```

### Slot

| Method | Path                           | Description                    | Protected (Role) |
| ------ | ------------------------------ | ------------------------------ | ---------------- |
| POST   | /parking/rows/\<row\_id>/slots | Create a new slot in a row     | Yes (user/admin) |
| GET    | /parking/rows/\<row\_id>/slots | Get all slots for a row        | Yes (user/admin) |
| GET    | /parking/slots/\<slot\_id>     | Get details of a specific slot | Yes (user/admin) |
| PUT    | /parking/slots/\<slot\_id>     | Update a slot                  | Yes (user/admin) |
| DELETE | /parking/slots/\<slot\_id>     | Delete a slot                  | Yes (user/admin) |

#### Example JSON for /parking/rows/\<row\_id>/slots (POST/PUT)

```json
{
  "name": "Slot 1",
  "status": 0,
  "vehicle_reg_no": "",
  "ticket_id": ""
}
```

---

### User Parking Sessions (`/user/sessions`)


#### 1. Check-In (Park Vehicle)

| Method | Path                    | Description                                 | Protected (Role) |
| ------ | ----------------------- | ------------------------------------------- | ---------------- |
| POST   | /user/sessions/check-in | Allocate a slot and start a parking session | Yes (user)       |

**Request JSON:**

```json
{
  "user_id": 12,
  "parkinglot_id": 5
}
```

**Success Response JSON:**

```json
{
  "ticket_id": "PK123456",
  "floor_name": 2,
  "row_name": "B",
  "slot_name": "Slot 14",
  "status": "active",
  "start_time": "2025-07-25T17:10:00Z"
}
```

**Failure Response JSON:**

```json
{
  "error": "Parking Full",
  "status": "failed"
}
```

---

#### 2. Checkout (Exit Vehicle)

| Method | Path                    | Description                          | Protected (Role) |
| ------ | ----------------------- | ------------------------------------ | ---------------- |
| POST   | /user/sessions/checkout | Checkout and close an active session(Before response of this API is send there is an handshake between admin app and cloud server via a different API confirming the payment is received) | Yes (user)       |

**Request JSON:**

```json
{
  "ticket_id": "PK123456"
}
```

**Success Response JSON:**

```json
{
  "message": "Checkout successful",
  "ticket_id": "PK123456",
  "slot_location": {
    "floor_name": 2,
    "row_name": "B",
    "slot_name": "Slot 14"
  },
  "start_time": "2025-07-25T16:00:00Z",
  "end_time": "2025-07-25T17:45:00Z",
  "duration_hrs": "1 hour 45 minutes",
  "amount_due": 40,
  "currency": "INR",
  "status": "completed"
}
```

**Failure Response JSON:**

```json
{
  "error": "Invalid or already completed ticket ID",
  "status": "failed"
}
```

---

#### 3. Get Active Sessions

| Method | Path                  | Description                         | Protected (Role) |
| ------ | --------------------- | ----------------------------------- | ---------------- |
| GET    | /user/sessions/active | Fetch all active sessions of a user | Yes (user)       |

**Query Param:** `?user_id=12`

**Response JSON:**

```json
[
  {
    "ticket_id": "PK123456",
    "slot_location": {
      "floor_name": 2,
      "row_name": "B",
      "slot_name": "Slot 14"
    },
    "start_time": "2025-07-25T16:00:00Z",
    "estimated_duration": "1 hour 45 minutes",
    "estimated_charge": 40,
    "currency": "INR",
    "status": "active"
  }
]
```

---

#### 4. Get Past Sessions (History)

| Method | Path                   | Description                             | Protected (Role) |
| ------ | ---------------------- | --------------------------------------- | ---------------- |
| GET    | /user/sessions/history | Get last 5 completed sessions of a user | Yes (user)       |

**Query Param:** `?user_id=12`

**Response JSON:**

```json
[
  {
    "ticket_id": "PK123455",
    "slot_location": {
      "floor_name": 1,
      "row_name": "A",
      "slot_name": "Slot 2"
    },
    "start_time": "2025-07-24T14:00:00Z",
    "end_time": "2025-07-24T15:30:00Z",
    "total_duration": "1 hour 30 minutes",
    "total_amount_paid": 40,
    "currency": "INR"
  }
]
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
- Parking charges are calculated at ₹20/hour (pro-rated).
- Time fields are ISO 8601 UTC timestamps.
- All endpoints require JWT authentication (`Authorization: Bearer <token>`).

