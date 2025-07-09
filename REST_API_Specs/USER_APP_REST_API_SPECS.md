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
|--------|----------------|----------------------------|-----------|
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
| Method | Path                        | Description                                      | Protected (Role) |
|--------|-----------------------------|--------------------------------------------------|------------------|
| POST   | /parking/lots               | Create a new parking lot                         | Yes (user/admin) |
| GET    | /parking/lots               | Get all parking lots (summary)                   | Yes (user/admin) |
| GET    | /parking/lots/<lot_id>      | Get details of a specific parking lot            | Yes (user/admin) |
| PUT    | /parking/lots/<lot_id>      | Update a parking lot                             | Yes (user/admin) |
| DELETE | /parking/lots/<lot_id>      | Delete a parking lot                             | Yes (user/admin) |
| GET    | /parking/lots/<lot_id>/stats| Get stats (total, occupied, available slots)     | Yes (user/admin) |

#### Example JSON for /parking/lots (POST/PUT)
```json
{
  "name": "Lot A",
  "address": "123 Main St",
  "description": "Main parking lot"
}
```

### Floor
| Method | Path                                   | Description                        | Protected (Role) |
|--------|----------------------------------------|------------------------------------|------------------|
| POST   | /parking/lots/<lot_id>/floors          | Create a new floor in a parking lot| Yes (user/admin) |
| GET    | /parking/lots/<lot_id>/floors          | Get all floors for a parking lot   | Yes (user/admin) |
| GET    | /parking/floors/<floor_id>             | Get details of a specific floor    | Yes (user/admin) |
| PUT    | /parking/floors/<floor_id>             | Update a floor                     | Yes (user/admin) |
| DELETE | /parking/floors/<floor_id>             | Delete a floor                     | Yes (user/admin) |

#### Example JSON for /parking/lots/<lot_id>/floors (POST/PUT)
```json
{
  "floor_number": 1,
  "description": "First floor"
}
```

### Row
| Method | Path                                         | Description                        | Protected (Role) |
|--------|----------------------------------------------|------------------------------------|------------------|
| POST   | /parking/floors/<floor_id>/rows              | Create a new row in a floor        | Yes (user/admin) |
| GET    | /parking/floors/<floor_id>/rows              | Get all rows for a floor           | Yes (user/admin) |
| GET    | /parking/rows/<row_id>                       | Get details of a specific row      | Yes (user/admin) |
| PUT    | /parking/rows/<row_id>                       | Update a row                       | Yes (user/admin) |
| DELETE | /parking/rows/<row_id>                       | Delete a row                       | Yes (user/admin) |

#### Example JSON for /parking/floors/<floor_id>/rows (POST/PUT)
```json
{
  "row_name": "A",
  "description": "Row A"
}
```

### Slot
| Method | Path                                             | Description                        | Protected (Role) |
|--------|--------------------------------------------------|------------------------------------|------------------|
| POST   | /parking/rows/<row_id>/slots                     | Create a new slot in a row         | Yes (user/admin) |
| GET    | /parking/rows/<row_id>/slots                     | Get all slots for a row            | Yes (user/admin) |
| GET    | /parking/slots/<slot_id>                         | Get details of a specific slot     | Yes (user/admin) |
| PUT    | /parking/slots/<slot_id>                         | Update a slot                      | Yes (user/admin) |
| DELETE | /parking/slots/<slot_id>                         | Delete a slot                      | Yes (user/admin) |

#### Example JSON for /parking/rows/<row_id>/slots (POST/PUT)
```json
{
  "name": "Slot 1",
  "status": 0,
  "vehicle_reg_no": "",
  "ticket_id": ""
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