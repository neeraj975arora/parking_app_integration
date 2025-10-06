# Parking Admin Dashboard - Setup Guide

This guide will help you set up and run the Parking Admin Dashboard React application with either the mock server or a Python backend.

## Prerequisites

- **Node.js** (version 18.0.0 or higher)
- **npm** (comes with Node.js)
- **Git** (for cloning the repository)

## Dependencies Overview

### React App Dependencies
The main React application requires the following dependencies:

**Production Dependencies:**
- `@tailwindcss/vite`: ^4.1.11
- `axios`: ^1.11.0
- `react`: ^19.1.0
- `react-dom`: ^19.1.0
- `react-router-dom`: ^7.7.1
- `recharts`: ^3.1.2
- `tailwindcss`: ^4.1.11

**Development Dependencies:**
- `@eslint/js`: ^9.30.1
- `@types/react`: ^19.1.8
- `@types/react-dom`: ^19.1.6
- `@vitejs/plugin-react`: ^4.6.0
- `eslint`: ^9.30.1
- `eslint-plugin-react-hooks`: ^5.2.0
- `eslint-plugin-react-refresh`: ^0.4.20
- `globals`: ^16.3.0
- `vite`: ^7.0.4

### Mock Server Dependencies
The mock server requires the following dependencies:

**Production Dependencies:**
- `express`: ^4.18.2
- `cors`: ^2.8.5
- `helmet`: ^7.1.0
- `morgan`: ^1.10.0
- `winston`: ^3.11.0
- `winston-daily-rotate-file`: ^4.7.1
- `jsonwebtoken`: ^9.0.2
- `bcryptjs`: ^2.4.3
- `joi`: ^17.11.0
- `express-rate-limit`: ^7.1.5
- `compression`: ^1.7.4
- `dotenv`: ^16.3.1

**Development Dependencies:**
- `nodemon`: ^3.0.2
- `jest`: ^29.7.0
- `supertest`: ^6.3.3

**Node.js Version Requirement:**
- `node`: >=18.0.0


## 1. Clone the Repository

```bash
git clone <repository-url>
cd admin_react_app
```

## 2. Install Dependencies

### Install React App Dependencies
```bash
npm install
```

### Install Mock Server Dependencies
```bash
cd mock-server
npm install
cd ..
```

## 3. Configuration

### API Endpoint Configuration

The React app connects to the backend through environment variables. You can configure the API endpoint in two ways:

#### Option A: Environment Variable (Recommended)
Create a `.env` file in the root directory:

```bash
# For Mock Server (default)
VITE_API_BASE_URL=http://localhost:3001

# For Python Backend (example)
# VITE_API_BASE_URL=http://localhost:8000

# For Production Backend (example)
# VITE_API_BASE_URL=https://your-production-api.com
```

#### Option B: Direct Code Modification
Edit `src/utils/constants.js` and modify the `API_BASE_URL`:

```javascript
// For Mock Server
//export const API_BASE_URL = 'http://localhost:3001'

// For Python Backend
 export const API_BASE_URL = 'http://localhost:80'

// For Production Backend
// export const API_BASE_URL = 'https://your-production-api.com'
```

## 4. Running the Application

### Option 1: Using Mock Server (Development/Testing)

#### Terminal 1 - Start Mock Server
```bash
cd mock-server
npm run dev
```
The mock server will start on `http://localhost:3001`

#### Terminal 2 - Start React App
```bash
npm run dev
```
The React app will start on `http://localhost:5173`

### Option 2: Using Python Backend

#### Terminal 1 - Start Python Backend
```bash
# Navigate to Backend directory
cd ../Backend

# Install dependencies (if not already done)
pip install -r app/requirements.txt

# Start Python backend
python wsgi.py
```
The Python backend will start on `http://localhost:8000`

#### Terminal 2 - Start React App
```bash
# Navigate back to React app directory
cd ../admin_react_app

# Update API configuration for Python backend
echo "VITE_API_BASE_URL=http://localhost:8000" > .env

# Start React app
npm run dev
```

## 5. Accessing the Application

1. Open your browser and navigate to `http://localhost:5173`
2. Use the following demo credentials to log in:

### Demo Credentials

#### For Mock Server:
**Super Admin:**
- Email: `superadmin@parking.com`
- Password: `password123`

**Admin:**
- Email: `admin@parking.com`
- Password: `password123`

#### For Python Backend:
**Super Admin Registration:**
To create a super admin, use the registration endpoint with the super admin secret:
```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user_name": "Super Admin",
    "user_email": "superadmin@parking.com",
    "user_password": "password123",
    "user_phone_no": "5555555555",
    "user_address": "HQ",
    "role": "super_admin",
    "super_admin_secret": "SUPER_SECRET_SUPER_ADMIN_KEY"
  }'
```

**Admin Registration (by Super Admin):**
After logging in as super admin, create admin users:
```bash
curl -X POST http://localhost:8000/admin/register_admin \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <super_admin_jwt_token>" \
  -d '{
    "user_name": "Admin User",
    "user_email": "admin@parking.com",
    "user_password": "admin123",
    "user_phone_no": "9876543210",
    "user_address": "HQ"
  }'
```

**Login Credentials:**
- **Super Admin**: `superadmin@parking.com` / `password123`
- **Admin**: `admin@parking.com` / `password123`

## 6. Available Scripts

### React App Scripts
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Run ESLint
```

### Mock Server Scripts
```bash
cd mock-server
npm start            # Start production server
npm run dev          # Start development server with nodemon
npm run seed         # Seed database with sample data
npm run reset        # Reset database
npm test             # Run tests
```


## 7. Port Configuration

### Default Ports
- **React App**: `5173` (Vite default)
- **Mock Server**: `3001`
- **Python Backend**: `8000`  or `5000` (Flask default)

### Changing Ports

#### React App Port
```bash
npm run dev -- --port 3000
```

#### Mock Server Port
Create a `.env` file in the `mock-server` directory:
```bash
PORT=3002
HOST=localhost
```

#### Python Backend Port
```bash
# Django
python manage.py runserver 8001

# Flask
python app.py --port 5001
```

## 8. Version Conflicts and Dependency Management

### Avoiding Version Conflicts

To ensure consistent installations across different environments, consider using:

#### Option 1: Use package-lock.json (Recommended)
The project includes `package-lock.json` files that lock specific versions:
```bash
# This will install exact versions from package-lock.json
npm ci
```

#### Option 2: Manual Version Specification
If you encounter conflicts, install specific versions:
```bash
# React App - Install exact versions
npm install @tailwindcss/vite@4.1.11 axios@1.11.0 react@19.1.0 react-dom@19.1.0 react-router-dom@7.7.1 recharts@3.1.2 tailwindcss@4.1.11

# Mock Server - Install exact versions
cd mock-server
npm install express@4.18.2 cors@2.8.5 helmet@7.1.0 morgan@1.10.0 winston@3.11.0 winston-daily-rotate-file@4.7.1 jsonwebtoken@9.0.2 bcryptjs@2.4.3 joi@17.11.0 express-rate-limit@7.1.5 compression@1.7.4 dotenv@16.3.1
```

#### Option 3: Clean Installation
If you encounter persistent issues:
```bash
# Remove node_modules and package-lock.json
rm -rf node_modules package-lock.json
rm -rf mock-server/node_modules mock-server/package-lock.json

# Reinstall everything
npm install
cd mock-server && npm install && cd ..
```

### Node.js Version Compatibility

**Required Node.js Version:** 18.0.0 or higher

Check your Node.js version:
```bash
node --version
npm --version
```

If you have an older version, update Node.js:
- Download from [nodejs.org](https://nodejs.org/)
- Or use a version manager like `nvm`:
```bash
# Install nvm (if not already installed)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install and use Node.js 18
nvm install 18
nvm use 18
```

## 9. Troubleshooting

### Common Issues

#### CORS Errors
If you encounter CORS errors when connecting to a Python backend, ensure your Python backend has CORS configured:

**Flask (Current Backend):**
```python
from flask_cors import CORS

# In your Flask app initialization
CORS(app, origins=["http://localhost:5173"])
```

**Django (Alternative):**
```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
]
```

#### Python Backend Issues
If you encounter issues with the Python backend:
- Ensure PostgreSQL is running
- Check that dependencies are installed: `pip install -r app/requirements.txt`
- Verify the backend is running on `http://localhost:8000`
- Check browser console for CORS errors

#### Port Already in Use
If a port is already in use:
```bash
# Find process using port
lsof -i :3001

# Kill process (replace PID with actual process ID)
kill -9 <PID>
```

#### Environment Variables Not Loading
Ensure your `.env` file is in the root directory and variables start with `VITE_`:
```bash
VITE_API_BASE_URL=http://localhost:3001
```

### Mock Server Specific

#### Reset Mock Data
```bash
cd mock-server
npm run reset
npm run seed
```

#### View Mock Server Logs
```bash
cd mock-server
tail -f logs/api-trace-$(date +%Y-%m-%d).log
```

## 10. Production Deployment

### Build React App
```bash
npm run build
```

### Serve Mock Server in Production
```bash
cd mock-server
npm start
```

### Environment Variables for Production
```bash
# React App (.env.production)
VITE_API_BASE_URL=https://your-production-api.com
```

## 11. API Documentation

### Mock Server API Documentation
The mock server includes comprehensive API documentation:
- **Swagger UI**: `http://localhost:3001/api-docs`
- **OpenAPI Spec**: `mock-server/docs/api/openapi.yaml`
- **Postman Collection**: `mock-server/docs/api/postman-collection.json`

### Python Backend API Documentation
- **Swagger UI**: `http://localhost:8000/apidocs`

## 12. Development Tips

### Hot Reload
- **React App**: Supports hot reload during development
- **Mock Server**: Supports hot reload with nodemon
- **Python Backend**: Supports hot reload with Flask development server

### API Testing
- **Mock Server**: Use Swagger UI at `http://localhost:3001/api-docs`
- **Python Backend**: Use Swagger UI at `http://localhost:8000/apidocs`
- **Postman**: Import collections from respective documentation folders

### Database Management
- **Mock Server**: Uses in-memory storage. Restart server to reset data
- **Python Backend**: Uses PostgreSQL. Use migrations for schema changes

### Logging
- **React App**: Logs appear in browser console
- **Mock Server**: Logs saved in `mock-server/logs/`
- **Python Backend**: Logs appear in console (configurable with logging libraries)

### Development Workflow
1. Start PostgreSQL database
2. Start Python backend: `python wsgi.py`
3. Start React app: `npm run dev`
4. Access admin dashboard at `http://localhost:5173`
5. Use Swagger UI for API testing and documentation
