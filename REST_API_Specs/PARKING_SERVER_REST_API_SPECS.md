## RPi/IoT API Endpoints (`/api/v1`)

| Method | Path                        | Description                                 | Protected |
|--------|-----------------------------|---------------------------------------------|-----------|
| POST   | /api/v1/slots/update_status | Update the status of a parking slot (IoT)   | API Key   |

## API_KEY = "super-secret-rpi-key"
## headers={"X-API-KEY": API_KEY}
#### Example JSON for /api/v1/slots/update_status
```json
{
  "id": 1,
  "status": 1
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