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
| Method | Path                        | Description                                      | Protected |
|--------|-----------------------------|--------------------------------------------------|-----------|
| POST   | /parking/lots               | Create a new parking lot                         | Yes       |
| GET    | /parking/lots               | Get all parking lots (summary)                   | Yes       |
| GET    | /parking/lots/<lot_id>      | Get details of a specific parking lot            | Yes       |
| PUT    | /parking/lots/<lot_id>      | Update a parking lot                             | Yes       |
| DELETE | /parking/lots/<lot_id>      | Delete a parking lot                             | Yes       |
| GET    | /parking/lots/<lot_id>/stats| Get stats (total, occupied, available slots)     | Yes       |

#### Example JSON for /parking/lots (POST/PUT)
```json
{
  "name": "Lot A",
  "address": "123 Main St",
  "description": "Main parking lot"
}
```

### Floor
| Method | Path                                   | Description                        | Protected |
|--------|----------------------------------------|------------------------------------|-----------|
| POST   | /parking/lots/<lot_id>/floors          | Create a new floor in a parking lot| Yes       |
| GET    | /parking/lots/<lot_id>/floors          | Get all floors for a parking lot   | Yes       |
| GET    | /parking/floors/<floor_id>             | Get details of a specific floor    | Yes       |
| PUT    | /parking/floors/<floor_id>             | Update a floor                     | Yes       |
| DELETE | /parking/floors/<floor_id>             | Delete a floor                     | Yes       |

#### Example JSON for /parking/lots/<lot_id>/floors (POST/PUT)
```json
{
  "floor_number": 1,
  "description": "First floor"
}
```

### Row
| Method | Path                                         | Description                        | Protected |
|--------|----------------------------------------------|------------------------------------|-----------|
| POST   | /parking/floors/<floor_id>/rows              | Create a new row in a floor        | Yes       |
| GET    | /parking/floors/<floor_id>/rows              | Get all rows for a floor           | Yes       |
| GET    | /parking/rows/<row_id>                       | Get details of a specific row      | Yes       |
| PUT    | /parking/rows/<row_id>                       | Update a row                       | Yes       |
| DELETE | /parking/rows/<row_id>                       | Delete a row                       | Yes       |

#### Example JSON for /parking/floors/<floor_id>/rows (POST/PUT)
```json
{
  "row_name": "A",
  "description": "Row A"
}
```

### Slot
| Method | Path                                             | Description                        | Protected |
|--------|--------------------------------------------------|------------------------------------|-----------|
| POST   | /parking/rows/<row_id>/slots                     | Create a new slot in a row         | Yes       |
| GET    | /parking/rows/<row_id>/slots                     | Get all slots for a row            | Yes       |
| GET    | /parking/slots/<slot_id>                         | Get details of a specific slot     | Yes       |
| PUT    | /parking/slots/<slot_id>                         | Update a slot                      | Yes       |
| DELETE | /parking/slots/<slot_id>                         | Delete a slot                      | Yes       |

#### Example JSON for /parking/rows/<row_id>/slots (POST/PUT)
```json
{
  "name": "Slot 1",
  "status": 0,
  "vehicle_reg_no": "",
  "ticket_id": ""
}
```

## RPi/IoT API Endpoints (`/api/v1`)

| Method | Path                        | Description                                 | Protected |
|--------|-----------------------------|---------------------------------------------|-----------|
| POST   | /api/v1/slots/update_status | Update the status of a parking slot (IoT)   | API Key   |

#### Example JSON for /api/v1/slots/update_status
```json
{
  "id": 1,
  "status": 1
}
```

---
**Note:**
- `Protected: Yes` means the endpoint requires a valid JWT access token in the `Authorization` header (e.g., `Bearer <token>`).
- `Protected: API Key` means the endpoint requires a valid API key in the `X-API-KEY` header.
- `Protected: No` means the endpoint is public and does not require authentication.

---
**Note:** Most endpoints (except `/auth` and `/api/v1/slots/update_status`) require JWT authentication in the `Authorization` header. 