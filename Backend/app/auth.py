import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from .models import User
from . import db
from flask_jwt_extended import jwt_required, get_jwt_identity

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Register a new user or super admin.
    ---
    tags:
      - Authentication
    description: |
      This endpoint registers a new user (default) or a super admin.
      
      - To register as a **regular user**: Omit the `role` field or set `role` to `user` (default). No secret required.
      - To register as a **super_admin**: Set `role` to `super_admin` and provide the correct `super_admin_secret`.
      
      **Example payloads:**
      
      *User registration:*
        {
          "user_name": "John Doe",
          "user_email": "john@example.com",
          "user_password": "password123",
          "user_phone_no": "1234567890",
          "user_address": "123 Main St"
        }
      
      *Super Admin registration:*
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
              description: "Role to register as. Defaults to 'user'. Only 'super_admin' requires a secret."
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
        description: "Invalid or missing super_admin secret"
    """
    data = request.get_json()
    # Check if user already exists
    if User.query.filter_by(user_email=data.get('user_email')).first():
        return jsonify({"msg": "User with this email already exists"}), 409
    if User.query.filter_by(user_phone_no=data.get('user_phone_no')).first():
        return jsonify({"msg": "User with this phone number already exists"}), 409
    # Determine role
    role = 'user'
    super_admin_secret = data.get('super_admin_secret')
    if data.get('role') == 'super_admin' and super_admin_secret == 'SUPER_SECRET_SUPER_ADMIN_KEY':
        role = 'super_admin'
    elif data.get('role') == 'super_admin':
        return jsonify({"msg": "Invalid or missing super admin secret"}), 403
    elif data.get('role') and data.get('role') != 'user':
        return jsonify({"msg": "Only user and super_admin registration allowed here"}), 403
    # Create new user
    new_user = User(
        user_name=data.get('user_name'),
        user_email=data.get('user_email'),
        user_phone_no=data.get('user_phone_no'),
        user_address=data.get('user_address'),
        role=role
    )
    new_user.set_password(data.get('user_password'))
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"msg": "User registered successfully", "role": new_user.role}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    User/Admin/Super Admin Login
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        schema:
          type: object
          required:
            - user_email
            - user_password
          properties:
            user_email:
              type: string
            user_password:
              type: string
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
      401:
        description: Bad email or password
    """
    data = request.get_json()
    email = data.get('user_email', None)
    password = data.get('user_password', None)

    user = User.query.filter_by(user_email=email).first()

    if user and user.check_password(password):
        payload = {
            "user_id": user.user_id,
            "role": user.role,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=12)
        }
        secret = current_app.config.get('SECRET_KEY', 'dev_secret')
        token = jwt.encode(payload, secret, algorithm="HS256")
        return jsonify({
            "access_token": token,
            "username": user.user_name,
            "user_email": user.user_email,
            "user_id": user.user_id,
            "user_address": user.user_address,
            "user_phone_no": user.user_phone_no,
            "role": user.role
        }), 200
    
    return jsonify({"msg": "Bad email or password"}), 401 