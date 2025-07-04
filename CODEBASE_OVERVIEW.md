# Codebase Overview

This document provides a high-level overview of the backend codebase for the Smart Parking System project. It is designed to help you quickly understand the structure, main components, and flow of the application.

---

## Project Structure

```
Backend/
├── app/                  # Main application code
│   ├── __init__.py       # App factory, extension initialization, blueprint registration
│   ├── main.py           # Landing page route
│   ├── config.py         # Configuration (env vars, DB URI, secrets)
│   ├── models.py         # SQLAlchemy ORM models (Users, ParkingLot, Floor, Row, Slot, etc.)
│   ├── auth.py           # Authentication routes (register, login)
│   ├── parking.py        # Parking lot, floor, row, slot CRUD API
│   ├── api_v1.py         # IoT/RPi API endpoints (slot status update)
│   ├── templates/        # HTML templates (landing page)
│   ├── requirements.txt  # Python dependencies
│   └── migrations/       # Alembic DB migrations
├── db/                   # Initial SQL scripts
├── nginx/                # Nginx reverse proxy config
├── tests/                # Pytest test suite
├── Dockerfile            # Docker build for Flask app
├── docker-compose.yml    # Multi-container orchestration (app, db, nginx)
├── README.md             # Project setup and usage instructions
├── API_ENDPOINTS.md      # API documentation (endpoints, JSON, auth)
└── CODEBASE_OVERVIEW.md  # (This file)
```

---

## Main Components

### 1. Flask Application (`app/`)
- **App Factory (`__init__.py`)**: Sets up Flask, SQLAlchemy, JWT, Marshmallow, Swagger, and registers blueprints.
- **Blueprints**:
  - `main.py`: Serves the root landing page (`/`).
  - `auth.py`: Handles user registration and login (`/auth`).
  - `parking.py`: CRUD for parking lots, floors, rows, slots (`/parking`).
  - `api_v1.py`: IoT endpoint for slot status updates (`/api/v1`).
- **Models (`models.py`)**: Defines ORM models for users and parking structure (ParkingLotDetails, Floor, Row, Slot, etc.).
- **Config (`config.py`)**: Loads environment variables, DB URI, secret keys, and API key for IoT.
- **Templates**: Contains `index.html` for the root landing page.

### 2. Database
- **PostgreSQL**: Used as the main database, managed via Docker Compose.
- **SQLAlchemy**: ORM for defining and interacting with database tables.
- **Alembic**: Handles database migrations (schema changes over time).
- **`db/init.sql`**: Optional initial SQL setup script.

### 3. Authentication
- **JWT (JSON Web Token)**: Used for securing most API endpoints (except registration, login, and IoT endpoint).
- **Flask-JWT-Extended**: Handles token creation and validation.
- **API Key**: Used for `/api/v1/slots/update_status` endpoint (for IoT devices).

### 4. API Documentation
- **Swagger UI (Flasgger)**: Interactive API docs available at `/apidocs`.
- **API_ENDPOINTS.md**: Markdown summary of all endpoints, JSON formats, and authentication requirements.

### 5. Docker & Nginx
- **Dockerfile**: Builds the Flask app image.
- **docker-compose.yml**: Orchestrates app, db, and nginx containers.
- **nginx/nginx.conf**: Reverse proxy for routing HTTP requests to the Flask app.

### 6. Testing
- **tests/**: Contains pytest-based unit/integration tests for authentication and parking APIs.
- **e2e_test.py**: End-to-end test script for the full stack.

---

## Application Flow

1. **User/Client** sends HTTP requests to the Nginx reverse proxy.
2. **Nginx** forwards requests to the Flask app container.
3. **Flask App** processes requests:
   - Auth endpoints (`/auth`) handle registration/login and return JWTs.
   - Parking endpoints (`/parking`) require JWT in the `Authorization` header.
   - IoT endpoint (`/api/v1/slots/update_status`) requires an API key in the `X-API-KEY` header.
4. **Database** operations are performed via SQLAlchemy ORM models.
5. **Responses** are returned as JSON (or HTML for the root page).
6. **Swagger UI** at `/apidocs` allows interactive API exploration.

---

## Key Points for Interview
- **Separation of concerns**: Auth, parking, and IoT APIs are modularized via Flask blueprints.
- **Security**: JWT for user APIs, API key for device APIs.
- **Scalability**: Docker Compose enables easy scaling and local development.
- **Documentation**: Both Swagger UI and markdown docs for clear API usage.
- **Testing**: Pytest suite ensures reliability of core features.

---

For more details, see the `README.md` and `API_ENDPOINTS.md` files. 