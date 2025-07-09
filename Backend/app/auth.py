import jwt
import datetime
from flask import Blueprint, request, jsonify, current_app
from .models import User
from . import db

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/register', methods=['POST'])
def register():
    """
    User Registration
    ---
    tags:
      - Authentication
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
    responses:
      201:
        description: User registered successfully
      400:
        description: Invalid input
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
    admin_secret = data.get('admin_secret')
    if data.get('role') == 'super_admin' and super_admin_secret == 'SUPER_SECRET_SUPER_ADMIN_KEY':
        role = 'super_admin'
    elif data.get('role') == 'admin' and admin_secret == 'SUPER_SECRET_ADMIN_KEY':
        role = 'admin'
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

@auth_bp.route('/register_super_admin', methods=['POST'])
def register_super_admin():
    data = request.get_json()
    # Require a special secret for super admin registration
    super_admin_secret = data.get('super_admin_secret')
    if super_admin_secret != 'SUPER_SECRET_SUPER_ADMIN_KEY':
        return jsonify({"msg": "Invalid or missing super admin secret"}), 403
    # Check if user already exists
    if User.query.filter_by(user_email=data.get('user_email')).first():
        return jsonify({"msg": "User with this email already exists"}), 409
    if User.query.filter_by(user_phone_no=data.get('user_phone_no')).first():
        return jsonify({"msg": "User with this phone number already exists"}), 409
    new_user = User(
        user_name=data.get('user_name'),
        user_email=data.get('user_email'),
        user_phone_no=data.get('user_phone_no'),
        user_address=data.get('user_address'),
        role='super_admin'
    )
    new_user.set_password(data.get('user_password'))
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"msg": "Super admin registered successfully", "role": new_user.role}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    """
    User Login
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
        description: Login successful, returns access token and username
      401:
        description: Bad username or password
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