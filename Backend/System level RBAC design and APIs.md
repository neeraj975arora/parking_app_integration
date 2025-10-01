## Authentication & Authorization Design

#### Note: This is a system level document detailing RBAC design and APIs for entire parking solution cutting across all apps, so information provided below should override any RBAC information covered in individual PRD and API documents.


Our Smart Parking System backend implements a robust role-based authentication system using JWT (JSON Web Tokens) and secure user-role management. This design supports seamless onboarding, secure access control, and administrative delegation for various user types.

### Roles & Permissions

We support three roles stored in the users table:

- **user** (default): Regular parking app user
- **admin**: Manages assigned parking lots
- **super_admin**: Has platform-level privileges including creating/removing admins, assigning lots, and overseeing the system

Each user's role is stored in a dedicated `role` field in the database and is encoded into the JWT returned on login. All protected backend endpoints authorize access based on this role.

### Registration & Login Endpoints

#### POST /auth/register (to be used only for mobile app with role user and no registration is required for other 2 roles i.e. admin and super admin)

Registers a new user.

- Regular users can register freely (role defaults to user). 
- To register as a regular user: Omit the role field or set role to user (default). Mobile app won't be sending any value for role field, default value user will be populated in the database by backend automatically.
- To register as a super_admin, the request must include a valid `super_admin_secret`.

#### Example Registration Payloads

Regular User Registration:
```json
{
  "user_name": "John Doe",
  "user_email": "john@example.com",
  "user_password": "password123",
  "user_phone_no": "1234567890",
  "user_address": "123 Main St"
}
```
Response
```json
{
  "msg": "User registered successfully",
  "role": "user"
}
```

Super Admin Registration:
```json
{
  "user_name": "Super Admin",
  "user_email": "superadmin@example.com",
  "user_password": "superpass",
  "user_phone_no": "5555555555",
  "user_address": "HQ",
  "role": "super_admin",
  "super_admin_secret": "SUPER_SECRET_SUPER_ADMIN_KEY"
}
```
Response
```json
{
  "msg": "Super Admin registered successfully",
  "role": "super_admin"
}
```

#### POST /auth/login (To be used by user android app)

Authenticates any user role and returns a JWT containing `user_id` and `role`.

#### Example Login Payloads

Request for Super Admin login
```json
{
  "user_email": "superadmin@parking.com",
  "user_password": "password123",
  "role": "super_admin"
}
```
Response
```json
{
  "access_token": "<JWT_TOKEN>",
  "role": "super_admin",
  "user_address": "HQ",
  "user_email": "superadmin@parking.com",
  "user_id": 1,
  "user_phone_no": "9876543210",
  "username": "Super Admin"
}
```
Request for Admin login
```json
{
  "user_email": "john@example.com",
  "user_password": "password123",
  "role": "admin"
}
```
Response
```json
{
  "access_token": "<JWT_TOKEN>",
  "role": "admin",
  "user_address": "HQ",
  "user_email": "john@example.com",
  "user_id": 2,
  "user_phone_no": "9876543210",
  "username": "John Doe"
}
```

Request for user login
```json
{
  "user_email": "john@example.com",
  "user_password": "password123",
  "role": "user"
}
```
Response
```json
{
  "access_token": "<JWT_TOKEN>",
  "role": "user",
  "user_address": "HQ",
  "user_email": "john@example.com",
  "user_id": 3,
  "user_phone_no": "9876543210",
  "username": "John Doe"
}
```






### JWT-Based Session & Authorization

Upon successful login, a signed JWT is issued, embedding:

- `user_id`
- `role`
- `expiry`

This token must be attached to all protected API requests. Server-side middleware verifies the token and enforces access based on role-based privileges. For example:

- Only super_admins can call endpoints like `/admin/create`, `/admin/delete`, or `/lot/assign`
- Admins can manage parking operations for their assigned lots
- Users can only access their session and booking data

### One-Time Super Admin Bootstrapping (Jenkins-like Setup)

To improve deployment security, our system incorporates a one-time super admin setup mechanism, inspired by tools like Jenkins CI/CD:

- On the first startup (when no super_admin exists in the database), a special local endpoint becomes available which uses the same POST API for registration(e.g., `/auth/register` on localhost).
- This page contains a form requiring the user to define credentials for the initial super_admin.
- After a super_admin is successfully registered, this route is permanently disabled to prevent additional super_admins from being created via public registration.
- Any future super_admin creation can only be done by existing super_admins via admin dashboard workflows (with role-based access checks).

This one-time initialization guarantees that:

- The system always has one trusted entry point for administrative setup
- There is no open attack surface for external super_admin registration
- The local deployment environment maintains control over first-time configuration
