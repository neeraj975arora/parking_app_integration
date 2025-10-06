# 🐳 Docker Commands Guide - Parking App Integration

This comprehensive guide covers all Docker commands used in the Parking App Integration monorepo for managing the backend services, database, and testing.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Docker Compose Commands](#docker-compose-commands)
- [Database Management](#database-management)
- [Testing Commands](#testing-commands)
- [Development Workflow](#development-workflow)
- [Troubleshooting](#troubleshooting)

## 🔧 Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)



## 🚀 Docker Compose Commands

### Basic Container Management

```bash
# Build and start all services in background
docker-compose up --build -d

# Start services without rebuilding
docker-compose up -d

# Start services in foreground (with logs)
docker-compose up --build

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: This deletes database data)
docker-compose down -v

# Restart specific service
docker-compose restart app
docker-compose restart db
docker-compose restart nginx

# View running containers
docker-compose ps

# View logs for all services
docker-compose logs

# View logs for specific service
docker-compose logs app
docker-compose logs db
docker-compose logs nginx

# Follow logs in real-time
docker-compose logs -f app
```

### Container Management

```bash
# Execute commands in running container
docker-compose exec app bash
docker-compose exec db bash

# Run one-time commands in container
docker-compose exec app python manage.py migrate
docker-compose exec app pytest

# Copy files to/from container
docker cp local_file.txt backend-app-1:/app/local_file.txt
docker cp backend-app-1:/app/logs ./local_logs

# Remove specific container
docker-compose rm app
docker-compose rm db
```

## 🗄️ Database Management

### Database Initialization

#### Option A: Using Flask-Migrate (Recommended)

```bash
# 1. Initialize migration environment (first time only)
docker-compose exec app flask db init

# 2. Create initial migration
docker-compose exec app flask db migrate -m "Initial migration"

# 3. Apply migration to database
docker-compose exec app flask db upgrade

# 4. Create additional migrations
docker-compose exec app flask db migrate -m "Add new feature"

# 5. Apply new migrations
docker-compose exec app flask db upgrade
```

#### Option B: Using SQL Scripts

```bash
# Copy SQL files to database container
docker cp init_db.sql backend-db-1:/init_db.sql
docker cp seed_data.sql backend-db-1:/seed_data.sql
docker cp populate_parking_data.sql backend-db-1:/populate_parking_data.sql

# Execute initialization script
docker exec -it backend-db-1 psql -U parking_user -d parking_db -f /init_db.sql

# Execute seed data script
docker exec -it backend-db-1 psql -U parking_user -d parking_db -f /seed_data.sql

# Execute parking data population
docker exec -it backend-db-1 psql -U parking_user -d parking_db -f /populate_parking_data.sql
```

### Database Access and Management

```bash
# Connect to PostgreSQL database
docker-compose exec db psql -U parking_user -d parking_db

# Connect to database from host
docker exec -it backend-db-1 psql -U parking_user -d parking_db

# Backup database
docker-compose exec db pg_dump -U parking_user parking_db > backup.sql

# Restore database from backup
docker-compose exec -T db psql -U parking_user -d parking_db < backup.sql

# List all databases
docker-compose exec db psql -U parking_user -c "\l"

# List all tables
docker-compose exec db psql -U parking_user -d parking_db -c "\dt"
```

## 🧪 Testing Commands

### Unit and Integration Tests

```bash
# Run all tests
docker-compose exec app pytest

# Run tests with verbose output
docker-compose exec app pytest -v

# Run specific test file
docker-compose exec app pytest tests/test_auth.py
docker-compose exec app pytest tests/test_admin_api.py
docker-compose exec app pytest tests/test_parking.py

# Run specific test function
docker-compose exec app pytest tests/test_auth.py::test_user_registration -v

# Run tests with coverage
docker-compose exec app pytest --cov=app

# Run tests with HTML coverage report
docker-compose exec app pytest --cov=app --cov-report=html

# Run tests in parallel
docker-compose exec app pytest -n auto
```

### End-to-End Testing

```bash
# Run E2E test script
docker-compose exec app python e2e_test.py

# Run E2E test with specific configuration
docker-compose exec app python e2e_test.py --config=production
```

## 🔄 Development Workflow

### Development Mode

```bash
# Start services in development mode
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Rebuild specific service during development
docker-compose build app
docker-compose up -d app

# View real-time logs during development
docker-compose logs -f app
```

### Code Changes and Hot Reload

```bash
# Restart app container after code changes
docker-compose restart app

# Rebuild and restart app container
docker-compose up --build -d app

# Force rebuild without cache
docker-compose build --no-cache app
docker-compose up -d app
```

### Debugging

```bash
# Access container shell for debugging
docker-compose exec app bash

# Check container resource usage
docker stats

# Inspect container configuration
docker-compose config

# Check container logs for errors
docker-compose logs app | grep ERROR
docker-compose logs db | grep ERROR
```

## 🌐 Service Access

### Application URLs

```bash
# Main application
http://localhost

# API Documentation (Swagger UI)
http://localhost/apidocs

# Health check endpoint
curl http://localhost/health

# API endpoints
curl http://localhost/api/v1/parking/lots
```

### Port Mapping

- **Application**: `localhost:80` (via Nginx)
- **Database**: `localhost:5432`
- **Nginx**: `localhost:80`

## 🛠️ Troubleshooting

### Common Issues and Solutions

```bash
# Check if containers are running
docker-compose ps

# Check container logs for errors
docker-compose logs app
docker-compose logs db

# Restart all services
docker-compose down
docker-compose up --build -d

# Clean up Docker resources
docker system prune -a

# Remove specific volumes
docker volume rm $(docker volume ls -q)

# Check disk space
docker system df

# View detailed container information
docker inspect backend-app-1
```

### Database Connection Issues

```bash
# Check database connectivity
docker-compose exec app python -c "from app import db; print('DB connected')"

# Reset database
docker-compose down -v
docker-compose up --build -d
docker-compose exec app flask db upgrade
```

### Permission Issues

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
```

## 📊 Monitoring and Maintenance

### Resource Monitoring

```bash
# Monitor container resource usage
docker stats

# Check container health
docker-compose ps

# View container resource limits
docker-compose config
```

### Log Management

```bash
# View recent logs
docker-compose logs --tail=100 app

# Save logs to file
docker-compose logs app > app_logs.txt

# Clear logs (restart containers)
docker-compose restart
```

### Cleanup Commands

```bash
# Remove stopped containers
docker-compose rm

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete cleanup (WARNING: Removes all unused Docker resources)
docker system prune -a
```

## 🔧 Custom Configuration

### Environment-Specific Deployments

```bash
# Production deployment
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Staging deployment
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

### Custom Dockerfile Modifications

```bash
# Build with custom Dockerfile
docker-compose build --build-arg BUILD_ENV=production app

# Use specific Dockerfile
docker-compose -f docker-compose.custom.yml up --build
```

---

## 📝 Quick Reference

| Command | Description |
|---------|-------------|
| `docker-compose up --build -d` | Start all services |
| `docker-compose down` | Stop all services |
| `docker-compose exec app bash` | Access app container |
| `docker-compose exec app pytest` | Run tests |
| `docker-compose logs -f app` | Follow app logs |
| `docker-compose restart app` | Restart app service |
| `docker-compose exec db psql -U parking_user -d parking_db` | Access database |

---

**Note**: Replace `backend-db-1` and `backend-app-1` with your actual container names if they differ. Use `docker-compose ps` to see the exact container names.
