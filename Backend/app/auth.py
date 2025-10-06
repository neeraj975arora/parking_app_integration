import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from .models import User
from . import db
from flask_jwt_extended import jwt_required, get_jwt_identity
from .config import setup_logging
import logging

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)
logger.info("Auth module initialized with centralized logging")

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

def check_super_admin_exists():
    """
    Check if a super admin already exists in the system.
    Returns True if super admin exists, False otherwise.
    """
    logger.debug("Checking if super admin exists in the system")
    try:
        super_admin = User.query.filter_by(role='super_admin').first()
        exists = super_admin is not None
        logger.debug(f"Super admin exists check result: {exists}")
        return exists
    except Exception as e:
        logger.error(f"Error checking super admin existence: {e}")
        return False

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Register a new user (mobile app only) or super admin.
    ---
    tags:
      - Authentication
    description: |
      This endpoint registers a new user (default) or a super admin.
      - To register as a **regular user**: Omit the `role` field or set `role` to `user` (default). No secret required.
      - To register as a **super_admin**: Set `role` to `super_admin` and provide the correct `super_admin_secret`.
      **Important Notes:**
      - This endpoint is primarily for mobile app user registration
      - Admin users are created only by super_admin via admin dashboard workflows
      - Only one super admin can exist in the system
      - Super admin registration is only allowed when no super admin exists
      - The secret must match: SUPER_SECRET_SUPER_ADMIN_KEY
      **Example payloads:**
      *User registration (mobile app):*
        {
          "user_name": "John Doe",
          "user_email": "john@example.com",
          "user_password": "password123",
          "user_phone_no": "1234567890",
          "user_address": "123 Main St"
        }
      *Super Admin registration (one-time setup):*
        {
          "user_name": "Super Admin",
          "user_email": "superadmin@example.com",
          "user_password": "superpass",
          "user_phone_no": "5555555555",
          "user_address": "HQ",
          "role": "super_admin",
          "super_admin_secret": "SUPER_SECRET_SUPER_ADMIN_KEY"
        }
    parameters:
      - in: body
        name: body
        schema:
          type: object
          required:
            - user_name
            - user_email
            - user_password
            - user_phone_no
          properties:
            user_name:
              type: string
            user_email:
              type: string
            user_password:
              type: string
            user_phone_no:
              type: string
            user_address:
              type: string
            role:
              type: string
              enum: [user, super_admin]
              description: "Role to register as. Defaults to 'user'. Only 'super_admin' requires a secret. Admin role cannot be registered via this endpoint."
            super_admin_secret:
              type: string
              description: "Required if role is 'super_admin'. Must match server secret."
    responses:
      201:
        description: "User or super_admin registered successfully"
      400:
        description: Invalid input
      409:
        description: User with this email or phone already exists
      403:
        description: "Invalid or missing super_admin secret, super admin already exists, or admin role not allowed"
      429:
        description: "Too many registration attempts"
    """
    data = request.get_json()
    logger.debug(f"POST /auth/register called with data: {data}")
    
    if not data:
        logger.warning("No data provided in registration request")
        return jsonify({"msg": "No data provided"}), 400
        
    # Validate required fields
    required_fields = ['user_name', 'user_email', 'user_password', 'user_phone_no']
    for field in required_fields:
        if not data.get(field):
            logger.warning(f"Missing required field in registration: {field}")
            return jsonify({"msg": f"Missing required field: {field}"}), 400
            
    # Validate email format
    if '@' not in data.get('user_email', ''):
        logger.warning(f"Invalid email format provided: {data.get('user_email')}")
        return jsonify({"msg": "Invalid email format"}), 400
        
    # Check if user already exists
    if User.query.filter_by(user_email=data.get('user_email')).first():
        logger.warning(f"Registration attempt with existing email: {data.get('user_email')}")
        return jsonify({"msg": "User with this email already exists"}), 409
        
    if User.query.filter_by(user_phone_no=data.get('user_phone_no')).first():
        logger.warning(f"Registration attempt with existing phone number: {data.get('user_phone_no')}")
        return jsonify({"msg": "User with this phone number already exists"}), 409
        
    # Determine role and handle super admin registration
    role = 'user'
    super_admin_secret = data.get('super_admin_secret')
    requested_role = data.get('role')
    
    if requested_role == 'super_admin':
        logger.info(f"Super admin registration attempt for email: {data.get('user_email')}")
        # Validate super admin secret
        if super_admin_secret != 'SUPER_SECRET_SUPER_ADMIN_KEY':
            logger.warning(f"Invalid super admin secret attempt from IP: {request.remote_addr}")
            return jsonify({"msg": "Invalid or missing super admin secret"}), 403
        # Check if super admin already exists
        if check_super_admin_exists():
            logger.warning(f"Super admin registration attempt when one already exists from IP: {request.remote_addr}")
            return jsonify({"msg": "Super admin already exists. Only one super admin is allowed per system."}), 403
        role = 'super_admin'
        logger.info(f"Super admin registration initiated for email: {data.get('user_email')}")
    elif requested_role == 'admin':
        # Admin role cannot be registered via this endpoint
        logger.warning(f"Admin registration attempt via public endpoint from IP: {request.remote_addr}")
        return jsonify({"msg": "Admin role cannot be registered via this endpoint. Admins are created by super_admin only."}), 403
    elif requested_role and requested_role != 'user':
        logger.warning(f"Invalid role registration attempt: {requested_role}")
        return jsonify({"msg": "Only 'user' and 'super_admin' roles are allowed"}), 403
        
    # Create new user
    try:
        new_user = User(
            user_name=data.get('user_name'),
            user_email=data.get('user_email'),
            user_phone_no=data.get('user_phone_no'),
            user_address=data.get('user_address', ''),
            role=role
        )
        new_user.set_password(data.get('user_password'))
        
        db.session.add(new_user)
        db.session.commit()
        
        if role == 'super_admin':
            logger.info(f"Super admin successfully registered: {data.get('user_email')}")
            return jsonify({
                "msg": "Super Admin registered successfully",
                "role": new_user.role,
                "warning": "This is the only super admin account allowed in the system."
            }), 201
        else:
            logger.info(f"User successfully registered: {data.get('user_email')}")
            return jsonify({"msg": "User registered successfully", "role": new_user.role}), 201
            
    except Exception as e:
        db.session.rollback()
        logger.exception(f"Database error during registration: {e}")
        return jsonify({"msg": "Registration failed due to database error"}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    User/Admin/Super Admin Login
    ---
    tags:
      - Authentication
    description: |
      Authenticates any user role and returns a JWT containing user_id and role.
      The role field in the request helps identify the intended login type.
    parameters:
      - in: body
        name: body
        schema:
          type: object
          required:
            - user_email
            - user_password
            - role
          properties:
            user_email:
              type: string
            user_password:
              type: string
            role:
              type: string
              enum: [user, admin, super_admin]
              description: "Role of the user attempting to login"
    responses:
      200:
        description: "Login successful, returns access token (JWT) and user info (role: user, admin, or super_admin)"
        schema:
          type: object
          properties:
            access_token:
              type: string
              description: "JWT access token (required for all protected endpoints)"
            username:
              type: string
            user_email:
              type: string
            user_id:
              type: integer
            user_address:
              type: string
            user_phone_no:
              type: string
            role:
              type: string
        examples:
          application/json:
            access_token: "<JWT_TOKEN>"
            username: "adminuser"
            user_email: "admin@example.com"
            user_id: 2
            user_address: "HQ"
            user_phone_no: "9876543210"
            role: "admin"
      400:
        description: Missing required fields
      401:
        description: Bad email or password
    """
    data = request.get_json()
    logger.debug(f"POST /auth/login called with data: {data}")
    
    if not data:
        logger.warning("No data provided in login request")
        return jsonify({"msg": "No data provided"}), 400
        
    email = data.get('user_email', '').strip()
    password = data.get('user_password', '')
    requested_role = data.get('role', 'user').strip()  # Default to 'user' if not provided
    
    if not email or not password:
        logger.warning(f"Missing required fields in login: email={bool(email)}, password={bool(password)}")
        return jsonify({"msg": "Email and password are required"}), 400
    
    # Validate role
    if requested_role not in ['user', 'admin', 'super_admin']:
        logger.warning(f"Invalid role in login request: {requested_role}")
        return jsonify({"msg": "Invalid role. Must be 'user', 'admin', or 'super_admin'"}), 400
    
    logger.debug(f"Attempting login for email: {email}, role: {requested_role}")
    user = User.query.filter_by(user_email=email).first()
    
    if user and user.check_password(password):
        # Verify the user's actual role matches the requested role
        if user.role != requested_role:
            logger.warning(f"Role mismatch for user: {email}. Requested: {requested_role}, Actual: {user.role}")
            return jsonify({"msg": "Invalid credentials for the specified role"}), 401
        
        # Log successful login
        logger.info(f"Successful login for user: {email} (Role: {user.role})")
        
        try:
            payload = {
                "user_id": user.user_id,
                "role": user.role,
                "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=12)
            }
            secret = current_app.config.get('JWT_SECRET_KEY') or current_app.config.get('SECRET_KEY')
            token = jwt.encode(payload, secret, algorithm="HS256")
            
            logger.info(f"JWT token generated successfully for user: {email}")
            return jsonify({
                "access_token": token,
                "username": user.user_name,
                "user_email": user.user_email,
                "user_id": user.user_id,
                "user_address": user.user_address,
                "user_phone_no": user.user_phone_no,
                "role": user.role
            }), 200
        except Exception as e:
            logger.exception(f"Error generating JWT token for user: {email}, error: {str(e)}")
            return jsonify({"msg": "Internal server error during token generation"}), 500
    else:
        # Log failed login attempt
        logger.warning(f"Failed login attempt for email: {email}")
        return jsonify({"msg": "Bad email or password"}), 401

@auth_bp.route('/super-admin-status', methods=['GET'])
def super_admin_status():
    """
    Check if a super admin exists in the system.
    This endpoint is useful for the frontend to determine if super admin registration is still allowed.
    ---
    tags:
      - Authentication
    responses:
      200:
        description: "Status of super admin existence"
        schema:
          type: object
          properties:
            super_admin_exists:
              type: boolean
              description: "True if super admin exists, False otherwise"
            can_register:
              type: boolean
              description: "True if super admin registration is allowed"
    """
    logger.debug("GET /auth/super-admin-status called")
    try:
        super_admin_exists = check_super_admin_exists()
        logger.info(f"Super admin status check completed: exists={super_admin_exists}")
        return jsonify({
            "super_admin_exists": super_admin_exists,
            "can_register": not super_admin_exists
        }), 200
    except Exception as e:
        logger.exception(f"Error checking super admin status: {e}")
        return jsonify({"msg": "Error checking super admin status"}), 500