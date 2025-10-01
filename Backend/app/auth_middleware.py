import jwt
from flask import request, jsonify, current_app
from functools import wraps
from datetime import datetime
from .config import setup_logging
import logging

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)
logger.info("Auth middleware module initialized with centralized logging")

class AuthError(Exception):
    """Custom exception for authentication errors"""
    pass

def get_jwt_secret():
    """Get JWT secret with proper fallback"""
    return current_app.config.get('JWT_SECRET_KEY') or current_app.config.get('SECRET_KEY')

def decode_jwt_token(token):
    """Centralized JWT token decoding with consistent error handling"""
    logger.debug(f"Attempting to decode JWT token")
    try:
        secret = get_jwt_secret()
        payload = jwt.decode(token, secret, algorithms=["HS256"])
        logger.debug(f"JWT token decoded successfully for user_id: {payload.get('user_id')}")
        return payload
    except jwt.ExpiredSignatureError:
        logger.warning("JWT token has expired")
        raise AuthError("Token has expired")
    except jwt.InvalidTokenError:
        logger.warning("Invalid JWT token provided")
        raise AuthError("Invalid token")
    except Exception as e:
        logger.error(f"Token validation failed: {str(e)}")
        raise AuthError(f"Token validation failed: {str(e)}")

def role_required(required_role):
    """Centralized role-based access control decorator"""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            logger.debug(f"Role-based access control check for endpoint: {f.__name__}, required role: {required_role}")
            try:
                # Extract token from Authorization header
                auth_header = request.headers.get("Authorization")
                if not auth_header or not auth_header.startswith("Bearer"):
                    logger.warning("Missing or invalid authorization header")
                    return jsonify({"error": "Missing or invalid authorization header"}), 401
                
                token = auth_header.split(" ")[1]
                logger.debug(f"Extracted token from authorization header")
                payload = decode_jwt_token(token)
                user_role = payload.get("role")
                
                if not user_role:
                    logger.warning("Token missing role information")
                    return jsonify({"error": "Token missing role information"}), 401
                
                logger.debug(f"User role from token: {user_role}, required role: {required_role}")
                
                # Role validation logic
                if not _has_required_role(user_role, required_role):
                    logger.warning(f"Insufficient permissions. User role: {user_role}, Required: {required_role}")
                    return jsonify({"error": f"Insufficient permissions. Required: {required_role}"}), 403
                
                # Add user info to request context for use in endpoints
                request.current_user = {
                    'user_id': payload.get('user_id'),
                    'role': user_role
                }
                
                logger.info(f"Access granted for user_id: {payload.get('user_id')} with role: {user_role} to endpoint: {f.__name__}")
                return f(*args, **kwargs)
                
            except AuthError as e:
                logger.error(f"Authentication error: {str(e)}")
                return jsonify({"error": str(e)}), 401
            except Exception as e:
                logger.exception(f"Unexpected authentication error: {str(e)}")
                return jsonify({"error": "Authentication failed"}), 401
        return wrapper
    return decorator

def _has_required_role(user_role, required_role):
    """Check if user role has required permissions"""
    # Define what roles each user role can access
    role_permissions = {
        'super_admin': ['super_admin', 'admin', 'user'],
        'admin': ['admin', 'user'],
        'user': ['user']
    }
    
    # Check if the user's role can access the required role
    has_permission = required_role in role_permissions.get(user_role, [user_role])
    logger.debug(f"Role permission check: {user_role} -> {required_role} = {has_permission}")
    return has_permission

def get_current_user():
    """Helper function to get current user from request context"""
    current_user = getattr(request, 'current_user', None)
    logger.debug(f"Retrieved current user from request context: {current_user}")
    return current_user
