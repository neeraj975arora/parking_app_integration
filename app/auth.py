from flask import Blueprint, request, jsonify
from .models import User
from . import db
from flask_jwt_extended import create_access_token

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

    new_user = User(
        user_name=data.get('user_name'),
        user_email=data.get('user_email'),
        user_phone_no=data.get('user_phone_no'),
        user_address=data.get('user_address')
    )
    new_user.set_password(data.get('user_password'))
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({"msg": "User registered successfully"}), 201

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
        access_token = create_access_token(identity=str(user.user_id))
        return jsonify({
            "access_token": access_token,
            "username": user.user_name,
            "user_email": user.user_email,
            "user_id": user.user_id,
            "user_address": user.user_address,
            "user_phone_no": user.user_phone_no
        }), 200
    
    return jsonify({"msg": "Bad email or password"}), 401 