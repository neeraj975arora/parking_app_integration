
# Overview
The centralized cloud-server is the backend of a smart parking system aimed at reducing urban congestion, fuel waste, and time spent finding parking. It serves as the central data hub for the Android-based user-parking-app, Raspberry Pi-based per-parking-servers at each parking location, and the React-based admin server. This product is designed for municipal authorities, private parking operators, and end users (drivers) to enhance parking efficiency through real-time updates and data-driven management.

# Core Features
### Real-Time Slot Tracking
- **What it does:** Tracks availability of parking slots using video feed analysis.
- **Why it's important:** Helps users find slots quickly and reduces congestion.
- **How it works:** Raspberry Pi with a YOLO/OpenCV module detects and updates status via REST API.

### Hierarchical Parking Lot Management
- **What it does:** Models parking lots with floors, rows, and individual slots.
- **Why it's important:** Enables flexible handling of complex parking structures.
- **How it works:** SQLAlchemy-backed relational model with nested entities.

### REST API for Frontends
- **What it does:** Allows mobile apps and admin dashboards to fetch and interact with data.
- **Why it's important:** Powers the user and admin interfaces.
- **How it works:** Flask routes with proper data serialization and JWT/Flask-Login authentication.

### Dockerized Infrastructure
- **What it does:** Ensures portability and ease of deployment.
- **Why it's important:** Makes it easier to scale and manage the server stack.
- **How it works:** Docker + Docker Compose setup with separate services for backend, DB, and Nginx.

# User Experience
### User Personas
- **Drivers:** Want to find available slots with minimal effort.
- **Parking Admins:** Need real-time insights and control over parking lots.

### Key User Flows
- Drivers: App → Search Area → View Availability → Park → Exit.
- Admins: Dashboard → Monitor Slots → View Logs (Phase 2).

### UI/UX Considerations
- Simple, fast-loading mobile views.
- Admin dashboard built in React with data visualization capabilities.

# Technical Architecture
### System Components
- Flask Backend Server
- PostgreSQL Database
- Per-Parking-Servers (YOLO/OpenCV + REST Client)
- Nginx Reverse Proxy
- Dockerized Deployment

### Data Models
- `ParkingLotDetails`, `Floor`, `Row`, `Slot`, `ParkingSession`, `Users`

### APIs and Integrations
- REST API for data read/write between frontend, Raspberry Pi, and backend.

### Infrastructure Requirements
- Cloud VM or container host with support for Docker, PostgreSQL, and HTTPS.
- Raspberry Pi devices with camera modules at each parking lot.

# Development Roadmap
### MVP Requirements
- Flask server with complete data model
- REST APIs for data ingestion and mobile app access
- Per-parking-server endpoint and one demo unit
- Docker setup for backend, DB, and reverse proxy

### Future Enhancements
- Reservation system for parking slots
- Admin dashboard with analytics and payment logs
- Role-based access control
- Multi-tenancy for multiple cities/operators

# Logical Dependency Chain
1. Define database models and create Flask APIs (foundation)
2. Deploy one per-parking-server and test integration (demo visibility)
3. Implement Docker Compose and local dev environment
4. Build mobile app and admin dashboard UI components
5. Add advanced features like reservations and role management

# Risks and Mitigations
### Technical Challenges
- **Risk:** Real-time video analysis may lag or misidentify slots.
- **Mitigation:** Optimize YOLO model and fallback to manual admin override.

### MVP Clarity
- **Risk:** Overengineering early.
- **Mitigation:** Strict MVP scope: live slot updates, user registration, and slot search.

### Resource Constraints
- **Risk:** Limited Raspberry Pi devices.
- **Mitigation:** Simulate input and add physical devices progressively.

# Appendix
- YOLOv5/YOLOv8 model integrated with OpenCV
- Flask API spec (under /docs)
- Docker Compose setup (v3.8), with named volumes and environment variables
