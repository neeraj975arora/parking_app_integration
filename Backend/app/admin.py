from flask import Blueprint, request, jsonify, current_app
from .models import db, ParkingLotDetails, AdminParkingLot, ParkingSession, AdminPaymentLedger
from .auth_middleware import role_required, get_current_user
from .config import setup_logging
import logging
import uuid
from datetime import datetime, timedelta
# from app.models import Row, Floor, Slot, User, ParkingLot, Session
from app.models import Row, Floor,Slot, User

from sqlalchemy import and_
from datetime import date as date_cls

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)
logger.info("Admin module initialized with centralized logging")

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

# Authentication is now handled by centralized auth_middleware

@admin_bp.route('/register_admin', methods=['POST'])
@role_required("super_admin")
def register_admin():
    """
    Register a new admin user
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Register a new admin user. Only super_admin can register admins.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - user_name
            - user_email
            - user_password
            - user_phone_no
            - user_address
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
        description: Admin registered successfully
        schema:
          type: object
          properties:
            msg:
              type: string
            role:
              type: string
      400:
        description: Invalid input or missing fields
      409:
        description: Admin with this email or phone already exists
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    logger.debug(f"POST /admin/register_admin called with data: {data}")
    
    try:
        # Required fields
        required_fields = ['user_name', 'user_email', 'user_password', 'user_phone_no', 'user_address']
        for field in required_fields:
            if not data.get(field):
                logger.warning(f"Missing required field: {field}")
                return jsonify({"error": f"Field '{field}' is required."}), 400

        # Check if admin with email already exists
        if User.query.filter_by(user_email=data.get('user_email')).first():
            logger.warning(f"Admin registration attempt with existing email: {data.get('user_email')}")
            return jsonify({"error": "An admin with this email already exists."}), 409

        # Check if admin with phone already exists
        if User.query.filter_by(user_phone_no=data.get('user_phone_no')).first():
            logger.warning(f"Admin registration attempt with existing phone: {data.get('user_phone_no')}")
            return jsonify({"error": "An admin with this phone number already exists."}), 409

        # Create new admin user
        logger.info(f"Creating new admin user with email: {data.get('user_email')}")
        new_admin = User(
            user_name=data.get('user_name'),
            user_email=data.get('user_email'),
            user_phone_no=data.get('user_phone_no'),
            user_address=data.get('user_address'),
            role='admin'
        )
        new_admin.set_password(data.get('user_password'))
        
        db.session.add(new_admin)
        db.session.commit()
        
        logger.info(f"Admin created successfully with user_id: {new_admin.user_id}")
        return jsonify({
            "msg": "Admin registered successfully",
            "role": "admin"
        }), 201

    except Exception as e:
        db.session.rollback()
        logger.exception(f"Failed to create admin: {str(e)}")
        return jsonify({"error": f"Failed to create admin: {str(e)}"}), 500

@admin_bp.route('/assign_lot', methods=['POST'])
@role_required("super_admin")
def assign_lot_to_admin():
    """
    Assign a parking lot to an admin (create admin + assign lots)
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.

      Create a new admin user and assign parking lots to them in a single operation.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - name
            - email
            - password
            - assigned_lots
            - phone_no
            - address
          properties:
            name:
              type: string
            email:
              type: string
            password:
              type: string
            assigned_lots:
              oneOf:
                - type: integer
                - type: array
                  items:
                    type: integer
            phone_no:
              type: string
            address:
              type: string
            role:
              type: string
              default: "admin"
    responses:
      201:
        description: Admin created and lots assigned successfully
        schema:
          type: object
          properties:
            message:
              type: string
            user_id:
              type: integer
            role:
              type: string
            assigned_lots:
              type: array
              items:
                type: integer
      400:
        description: Invalid input or missing fields
      409:
        description: Admin with this email or phone_no already exists
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    logger.debug(f"POST /admin/assign_lot called with data: {data}")
    
    try:
        # Required fields (check presence in payload)
        required_fields = ['name', 'email', 'password', 'assigned_lots', 'phone_no', 'address']
        for field in required_fields:
            if field not in data:
                logger.warning(f"Missing required field: {field}")
                return jsonify({"error": f"Field '{field}' is required."}), 400
            # For string fields ensure non-empty values
            if field in ('name', 'email', 'password', 'phone_no', 'address') and not data.get(field):
                logger.warning(f"Empty value for required field: {field}")
                return jsonify({"error": f"Field '{field}' must not be empty."}), 400

        # Accept either single integer or array for assigned_lots; normalize to list of ints
        assigned_lots_raw = data.get('assigned_lots')
        lot_ids = []
        if isinstance(assigned_lots_raw, list):
            if len(assigned_lots_raw) == 0:
                logger.warning("Empty assigned_lots array provided")
                return jsonify({"error": "assigned_lots must be a non-empty array or a single integer."}), 400
            try:
                lot_ids = [int(x) for x in assigned_lots_raw]
                logger.debug(f"Converted assigned_lots array to integers: {lot_ids}")
            except Exception as e:
                logger.error(f"Error converting assigned_lots to integers: {str(e)}")
                return jsonify({"error": "All items in assigned_lots must be integers."}), 400
        else:
            # Single value (could be int or numeric string)
            try:
                lot_ids = [int(assigned_lots_raw)]
                logger.debug(f"Converted single assigned_lot to integer: {lot_ids}")
            except Exception as e:
                logger.error(f"Error converting assigned_lot to integer: {str(e)}")
                return jsonify({"error": "assigned_lots must be an integer or an array of integers."}), 400

        # Validate role (optional, defaults to 'admin')
        allowed_roles = {'admin'}
        role = data.get('role', 'admin')
        if role not in allowed_roles:
            logger.warning(f"Invalid role provided: {role}, allowed: {list(allowed_roles)}")
            return jsonify({"error": f"Invalid role. Allowed roles: {list(allowed_roles)}"}), 400

        # Check if admin with email already exists
        if User.query.filter_by(user_email=data.get('email')).first():
            logger.warning(f"Admin registration attempt with existing email: {data.get('email')}")
            return jsonify({"error": "An admin with this email already exists."}), 409

        # Validate that all assigned lots exist
        existing_lots = ParkingLotDetails.query.filter(ParkingLotDetails.id.in_(lot_ids)).all()
        existing_lot_ids = [lot.id for lot in existing_lots]

        if len(existing_lot_ids) != len(lot_ids):
            missing_lots = set(lot_ids) - set(existing_lot_ids)
            logger.warning(f"Non-existent parking lot IDs provided: {list(missing_lots)}")
            return jsonify({"error": f"One or more assigned parking lot IDs do not exist: {list(missing_lots)}"}), 400

        # Check if any lots are already assigned
        existing_assignments = AdminParkingLot.query.filter(AdminParkingLot.parking_lot_id.in_(lot_ids)).all()
        if existing_assignments:
            assigned_lot_ids = [assignment.parking_lot_id for assignment in existing_assignments]
            logger.warning(f"Attempt to assign already assigned lots: {assigned_lot_ids}")
            return jsonify({"error": f"One or more assigned parking lot IDs are already assigned: {assigned_lot_ids}"}), 400

        # Create new admin user
        logger.info(f"Creating new admin user with email: {data.get('email')}")
        new_admin = User(
            user_name=data.get('name'),
            user_email=data.get('email'),
            user_phone_no=data.get('phone_no'),
            user_address=data.get('address'),
            role=role
        )
        new_admin.set_password(data.get('password'))
        db.session.add(new_admin)
        db.session.flush()  # populate new_admin.user_id

        # Create lot assignments
        for lot_id in lot_ids:
            assignment = AdminParkingLot(
                admin_id=new_admin.user_id,
                parking_lot_id=lot_id
            )
            db.session.add(assignment)

        db.session.commit()
        logger.info(f"Admin created successfully with user_id: {new_admin.user_id}, assigned lots: {lot_ids}")

        return jsonify({
            "message": "Admin created successfully",
            "user_id": new_admin.user_id,
            "role": role,
            "assigned_lots": lot_ids
        }), 201

    except Exception as e:
        db.session.rollback()
        logger.exception(f"Failed to create admin and assign lots: {str(e)}")
        return jsonify({"error": f"Failed to create admin: {str(e)}"}), 500


@admin_bp.route('/assign_existing_lot', methods=['POST'])
@role_required("super_admin")
def assign_existing_lot_to_admin():
    """
    Assign an existing parking lot to an existing admin
    ---
    tags:
      - Admin
    description: |
      Assign an existing parking lot to an existing admin user.
    parameters:
      - in: body
        name: assignment_data
        required: true
        schema:
          type: object
          required:
            - admin_id
            - parking_lot_id
          properties:
            admin_id:
              type: integer
              description: ID of the admin user
            parking_lot_id:
              type: integer
              description: ID of the parking lot to assign
    responses:
      201:
        description: Lot assigned successfully
      400:
        description: Invalid input or missing fields
      404:
        description: Admin or parking lot not found
      409:
        description: Lot already assigned
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    logger.debug(f"POST /admin/assign_existing_lot called with data: {data}")
    
    try:
        # Required fields
        admin_id = data.get('admin_id')
        parking_lot_id = data.get('parking_lot_id')
        
        if not admin_id or not parking_lot_id:
            logger.warning("Missing required fields: admin_id or parking_lot_id")
            return jsonify({"error": "admin_id and parking_lot_id are required"}), 400
        
        # Validate admin exists and is an admin
        admin = User.query.filter_by(user_id=admin_id, role='admin').first()
        if not admin:
            logger.warning(f"Admin with ID {admin_id} not found")
            return jsonify({"error": "Admin not found"}), 404
        
        # Validate parking lot exists
        parking_lot = ParkingLotDetails.query.filter_by(id=parking_lot_id).first()
        if not parking_lot:
            logger.warning(f"Parking lot with ID {parking_lot_id} not found")
            return jsonify({"error": "Parking lot not found"}), 404
        
        # Check if lot is already assigned to this admin
        existing_assignment = AdminParkingLot.query.filter_by(
            admin_id=admin_id, 
            parking_lot_id=parking_lot_id
        ).first()
        
        if existing_assignment:
            logger.warning(f"Lot {parking_lot_id} already assigned to admin {admin_id}")
            return jsonify({"error": "Lot already assigned to this admin"}), 409
        
        # Create assignment
        assignment = AdminParkingLot(
            admin_id=admin_id,
            parking_lot_id=parking_lot_id,
            assigned_date=datetime.now().date()
        )
        
        db.session.add(assignment)
        db.session.commit()
        
        logger.info(f"Successfully assigned lot {parking_lot_id} to admin {admin_id}")
        return jsonify({
            "message": "Lot assigned successfully",
            "admin_id": admin_id,
            "parking_lot_id": parking_lot_id
        }), 201
        
    except Exception as e:
        db.session.rollback()
        logger.exception(f"Failed to assign lot to admin: {str(e)}")
        return jsonify({"error": f"Failed to assign lot: {str(e)}"}), 500


@admin_bp.route('/admin_lots/all', methods=['GET'])
@role_required("super_admin")
def get_all_admin_lots():
    """
    Get all parking lot details assigned to different admins
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get all admin-lot assignments for super admin management.
    responses:
      200:
        description: List of all admin lot assignments
        schema:
          type: object
          properties:
            meta:
              type: object
              properties:
                total:
                  type: integer
            data:
              type: array
              items:
                type: object
                properties:
                  user_id:
                    type: integer
                  user_name:
                    type: string
                  user_email:
                    type: string
                  user_phone_no:
                    type: string
                  user_address:
                    type: string
                  joining_date:
                    type: string
                    format: date-time
                  status:
                    type: string
                  assigned_lots:
                    type: array
                    items:
                      type: object
                      properties:
                        parkinglot_id:
                          type: integer
                        parking_name:
                          type: string
                        location:
                          type: object
                          properties:
                            address:
                              type: string
                            landmark:
                              type: string
                            coordinates:
                              type: object
                              properties:
                                latitude:
                                  type: number
                                longitude:
                                  type: number
                        parking_type:
                          type: string
                        assigned_date:
                          type: string
                          format: date-time
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/admin_lots/all called")
    
    try:
        # Get all admin-lot assignments with admin and parking lot details
        assignments = db.session.query(
            AdminParkingLot.admin_id,
            User.user_name,
            User.user_email,
            User.user_phone_no,
            User.user_address,
            User.created_on,
            AdminParkingLot.parking_lot_id,
            AdminParkingLot.assigned_date,
            ParkingLotDetails.name,
            ParkingLotDetails.address,
            ParkingLotDetails.landmark,
            ParkingLotDetails.latitude,
            ParkingLotDetails.longitude,
            ParkingLotDetails.parking_type
        ).join(
            User, AdminParkingLot.admin_id == User.user_id
        ).join(
            ParkingLotDetails, AdminParkingLot.parking_lot_id == ParkingLotDetails.id
        ).filter(
            User.role == 'admin'
        ).all()
        
        logger.debug(f"Found {len(assignments)} admin-lot assignments")
        
        # Group assignments by admin
        admin_lots = {}
        for assignment in assignments:
            admin_id = assignment.admin_id
            if admin_id not in admin_lots:
                admin_lots[admin_id] = {
                    'user_id': admin_id,
                    'user_name': assignment.user_name,
                    'user_email': assignment.user_email,
                    'user_phone_no': assignment.user_phone_no,
                    'user_address': assignment.user_address,
                    'joining_date': assignment.created_on.isoformat() + 'Z' if assignment.created_on else None,
                    'status': 'active',
                    'assigned_lots': []
                }
            
            # Add parking lot details
            lot_details = {
                'parkinglot_id': assignment.parking_lot_id,
                'parking_name': assignment.name,
                'location': {
                    'address': assignment.address,
                    'landmark': assignment.landmark,
                    'coordinates': {
                        'latitude': float(assignment.latitude) if assignment.latitude else None,
                        'longitude': float(assignment.longitude) if assignment.longitude else None
                    }
                },
                'parking_type': assignment.parking_type,
                'assigned_date': assignment.assigned_date.isoformat() + 'Z' if assignment.assigned_date else None
            }
            admin_lots[admin_id]['assigned_lots'].append(lot_details)
        
        # Convert to list format
        data = list(admin_lots.values())
        logger.info(f"Successfully retrieved admin lot assignments for {len(data)} admins")
        
        return jsonify({
            "meta": {
                "total": len(data)
            },
            "data": data
        }), 200
        
    except Exception as e:
        logger.exception(f"Failed to retrieve admin lot assignments: {str(e)}")
        return jsonify({"error": f"Failed to retrieve admin lot assignments: {str(e)}"}), 500

@admin_bp.route('/sessions/details/all', methods=['GET'])
@role_required("super_admin")
def get_all_sessions_details():
    """
    Get all parking session details for all admins (last 3 months)
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get all parking sessions for the last 3 months across all admins.
    responses:
      200:
        description: List of all parking sessions
        schema:
          type: array
          items:
            type: object
            properties:
              ticket_id:
                type: string
              parkinglot_id:
                type: integer
              vehicle_reg_no:
                type: string
              user_id:
                type: integer
              start_time:
                type: string
                format: date-time
              end_time:
                type: string
                format: date-time
                nullable: true
              duration_hrs:
                type: number
                nullable: true
              vehicle_type:
                type: string
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/sessions/details/all called")
    
    try:
        # Calculate date 3 months ago
        three_months_ago = datetime.utcnow() - timedelta(days=90)
        logger.debug(f"Querying sessions from: {three_months_ago}")

        
        # Get all sessions from last 3 months - no additional filtering needed for super admin
        sessions = ParkingSession.query.filter(
            ParkingSession.start_time != None,
            ParkingSession.start_time >= three_months_ago
        ).order_by(ParkingSession.start_time.desc()).all()
        
        logger.debug(f"Found {len(sessions)} sessions in the last 3 months")
        
        # Format sessions data according to API specs
        sessions_data = []
        for session in sessions:
            session_data = {
                "ticket_id": session.ticket_id,
                "parkinglot_id": session.parkinglot_id,
                "vehicle_reg_no": session.vehicle_reg_no,
                "user_id": session.user_id,
                "start_time": session.start_time.isoformat() + 'Z' if session.start_time else None,
                "end_time": session.end_time.isoformat() + 'Z' if session.end_time else None,
                "duration_hrs": float(session.duration_hrs) if session.duration_hrs else None,
                "amount_paid": float(session.amount_paid) if session.amount_paid else 0,
                "vehicle_type": session.vehicle_type
            }
            sessions_data.append(session_data)
        
        logger.info(f"Successfully retrieved {len(sessions_data)} session details")
        return jsonify(sessions_data), 200
        
    except Exception as e:
        logger.exception(f"Failed to retrieve sessions: {str(e)}")
        return jsonify({"error": f"Failed to retrieve sessions: {str(e)}"}), 500



@admin_bp.route('/remove_assignment', methods=['DELETE'])
@role_required("super_admin")
def remove_assignment():
    """
    Remove admin-lot assignment
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Remove admin-lot assignment. `parking_lot_id` may be a single integer or an array of integers.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            admin_id:
              type: integer
            parking_lot_id:
              # Accept either single integer or array of integers
              oneOf:
                - type: integer
                - type: array
                  items:
                    type: integer
    responses:
      200:
        description: Assignment(s) removed
      400:
        description: Invalid input
      404:
        description: Assignment not found
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    admin_id = data.get('admin_id')
    lot_input = data.get('parking_lot_id')

    # Validate admin_id
    if admin_id is None:
        logger.warning("Missing admin_id in remove_assignment request")
        return jsonify({'msg': 'admin_id is required'}), 400
    try:
        admin_id = int(admin_id)
        logger.debug(f"Converted admin_id to integer: {admin_id}")
    except Exception as e:
        logger.error(f"Invalid admin_id type: {str(e)}")
        return jsonify({'msg': 'admin_id must be an integer'}), 400

    # Validate parking_lot_id (single or list)
    if lot_input is None:
        logger.warning("Missing parking_lot_id in remove_assignment request")
        return jsonify({'msg': 'parking_lot_id is required (integer or array of integers)'}), 400

    # Normalize to list of ints
    lot_ids = []
    if isinstance(lot_input, list):
        if len(lot_input) == 0:
            logger.warning("Empty parking_lot_id array provided")
            return jsonify({'msg': 'parking_lot_id array must not be empty'}), 400
        try:
            lot_ids = [int(x) for x in lot_input]
            logger.debug(f"Converted parking_lot_id array to integers: {lot_ids}")
        except Exception as e:
            logger.error(f"Error converting parking_lot_id array to integers: {str(e)}")
            return jsonify({'msg': 'All items in parking_lot_id array must be integers'}), 400
    else:
        # single value (could be int or numeric string)
        try:
            lot_ids = [int(lot_input)]
            logger.debug(f"Converted single parking_lot_id to integer: {lot_ids}")
        except Exception as e:
            logger.error(f"Error converting parking_lot_id to integer: {str(e)}")
            return jsonify({'msg': 'parking_lot_id must be an integer or an array of integers'}), 400

    try:
        # Fetch existing assignments for this admin and the provided lot ids
        assignments = AdminParkingLot.query.filter(
            AdminParkingLot.admin_id == admin_id,
            AdminParkingLot.parking_lot_id.in_(lot_ids)
        ).all()

        if not assignments:
            logger.warning(f"No assignments found for admin_id: {admin_id} and parking_lot_ids: {lot_ids}")
            return jsonify({'msg': 'Assignment not found for given admin_id and parking_lot_id(s)'}), 404

        removed_ids = [a.parking_lot_id for a in assignments]
        logger.debug(f"Found {len(assignments)} assignments to remove. Parking lot IDs: {removed_ids}")

        # Delete found assignments
        for a in assignments:
            db.session.delete(a)
        db.session.commit()

        not_found = list(set(lot_ids) - set(removed_ids))
        logger.info(f"Assignment(s) removed successfully. Removed: {removed_ids}, Not found: {not_found}")

        response = {
            'msg': 'Assignment(s) removed',
            'removed_parking_lot_ids': removed_ids
        }
        if not_found:
            response['not_found_parking_lot_ids'] = not_found

        return jsonify(response), 200

    except Exception as e:
        db.session.rollback()
        logger.exception(f"Failed to remove assignment(s): {str(e)}")
        return jsonify({'msg': f'Failed to remove assignment(s): {str(e)}'}), 500


@admin_bp.route('/admin_lots/<int:admin_id>', methods=['GET'])
@role_required("admin")
def get_lots_for_admin(admin_id):
    """
    Get all lot IDs assigned to an admin
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get all lot IDs assigned to an admin with detailed parking lot information.
    parameters:
      - in: path
        name: admin_id
        type: integer
        required: true
    responses:
      200:
        description: Admin details with assigned parking lots
        schema:
          type: object
          properties:
            user_id:
              type: integer
            user_name:
              type: string
            user_email:
              type: string
            user_phone_no:
              type: string
            user_address:
              type: string
            joining_date:
              type: string
              format: date-time
            status:
              type: string
            assigned_lots:
              type: array
              items:
                type: object
                properties:
                  parkinglot_id:
                    type: integer
                  parking_name:
                    type: string
                  location:
                    type: object
                    properties:
                      address:
                        type: string
                      landmark:
                        type: string
                      coordinates:
                        type: object
                        properties:
                          latitude:
                            type: number
                          longitude:
                            type: number
                  parking_type:
                    type: string
                  assigned_date:
                    type: string
                    format: date-time
      404:
        description: Admin not found
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/admin_lots/{admin_id} called")
    try:
        # Get admin details
        admin = User.query.filter_by(user_id=admin_id, role='admin').first()
        if not admin:
            logger.warning(f"Admin not found with ID: {admin_id}")
            return jsonify({"error": "Admin not found"}), 404
        
        # Get admin's assigned lots with parking lot details
        assignments = db.session.query(
            AdminParkingLot.parking_lot_id,
            AdminParkingLot.assigned_date,
            ParkingLotDetails.name,
            ParkingLotDetails.address,
            ParkingLotDetails.landmark,
            ParkingLotDetails.latitude,
            ParkingLotDetails.longitude,
            ParkingLotDetails.parking_type
        ).join(
            ParkingLotDetails, AdminParkingLot.parking_lot_id == ParkingLotDetails.id
        ).filter(
            AdminParkingLot.admin_id == admin_id
        ).all()
        
        # Format assigned lots data
        assigned_lots = []
        for assignment in assignments:
            lot_details = {
                'parkinglot_id': assignment.parking_lot_id,
                'parking_name': assignment.name,
                'location': {
                    'address': assignment.address,
                    'landmark': assignment.landmark,
                    'coordinates': {
                        'latitude': float(assignment.latitude) if assignment.latitude else None,
                        'longitude': float(assignment.longitude) if assignment.longitude else None
                    }
                },
                'parking_type': assignment.parking_type,
                'assigned_date': assignment.assigned_date.isoformat() + 'Z' if assignment.assigned_date else None
            }
            assigned_lots.append(lot_details)
        
        # Format response according to API specs
        response_data = {
            'user_id': admin.user_id,
            'user_name': admin.user_name,
            'user_email': admin.user_email,
            'user_phone_no': admin.user_phone_no,
            'user_address': admin.user_address,
            'joining_date': admin.created_on.isoformat() + 'Z' if admin.created_on else None,
            'status': 'active',
            'assigned_lots': assigned_lots
        }
        logger.info(f"Successfully retrieved admin lots for admin_id: {admin_id}")
        return jsonify(response_data), 200
        
    except Exception as e:
        logger.exception(f"Failed to retrieve admin lots for admin_id: {admin_id}")
        return jsonify({"error": f"Failed to retrieve admin lots: {str(e)}"}), 500


@admin_bp.route('/sessions/details/<int:user_id>', methods=['GET'])
@role_required("admin")
def get_sessions_for_admin(user_id):
    """
    Get all parking session details for this admin (last 3 months)
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get all parking sessions for the current admin for the last 3 months.
      The user_id in the URL is ignored - the admin's user_id is automatically extracted from the JWT token.
    parameters:
      - in: path
        name: user_id
        type: integer
        required: true
        description: "This parameter is ignored - user_id is extracted from JWT token"
    responses:
      200:
        description: List of parking sessions for admin
        schema:
          type: array
          items:
            type: object
            properties:
              ticket_id:
                type: string
              parkinglot_id:
                type: integer
              vehicle_reg_no:
                type: string
              user_id:
                type: integer
              start_time:
                type: string
                format: date-time
              end_time:
                type: string
                format: date-time
                nullable: true
              duration_hrs:
                type: number
                nullable: true
              vehicle_type:
                type: string
    security:
      - Bearer: []
    """
    
    logger.debug(f"GET /admin/sessions/details/{user_id} called")
    
    try:

        # Get current user from JWT token (ignore the user_id parameter)
        current_user = get_current_user()
        admin_id = current_user["user_id"]
        logger.debug(f"Retrieved current user from JWT token: admin_id={admin_id}")
        
        # Verify the user is an admin
        admin = User.query.filter_by(user_id=admin_id, role='admin').first()
        if not admin:
            logger.warning(f"Admin not found with ID: {admin_id}")
            return jsonify({"error": "Admin not found"}), 404
        
        # Get admin's assigned lots
        admin_assignments = AdminParkingLot.query.filter_by(admin_id=admin_id).all()
        admin_lot_ids = [assignment.parking_lot_id for assignment in admin_assignments]
        
        if not admin_lot_ids:
            logger.info(f"No assigned lots found for admin_id: {admin_id}. Returning empty list.")
            return jsonify([]), 200
        
        # Calculate date 3 months ago
        three_months_ago = datetime.utcnow() - timedelta(days=90)
        logger.debug(f"Querying sessions from: {three_months_ago}")
        
        # Debug: Let's check what slots exist and their parkinglot_ids
        logger.debug(f"DEBUG: Admin lot IDs: {admin_lot_ids}")
        
        # Check all slots and their parkinglot_ids
        all_slots = Slot.query.all()
        logger.debug(f"DEBUG: Total slots in database: {len(all_slots)}")
        for slot in all_slots[:5]:  # Show first 5 slots
            logger.debug(f"DEBUG: Slot ID: {slot.id}, ParkingLot ID: {slot.parkinglot_id}")
        
        # Check all sessions and their slot_ids
        all_sessions = ParkingSession.query.all()
        logger.debug(f"DEBUG: Total sessions in database: {len(all_sessions)}")
        for session in all_sessions:
            logger.debug(f"DEBUG: Session {session.ticket_id}, Slot ID: {session.slot_id}, Start: {session.start_time}")
        
        # Try a different approach - get sessions and check their slots manually
        all_sessions = ParkingSession.query.filter(
            ParkingSession.start_time >= three_months_ago
        ).all()
        
        logger.debug(f"DEBUG: Found {len(all_sessions)} sessions in date range")
        
        sessions = []
        for session in all_sessions:
            if session.slot_id:
                slot = Slot.query.filter_by(id=session.slot_id).first()
                if slot and slot.parkinglot_id in admin_lot_ids:
                    sessions.append(session)
                    logger.debug(f"DEBUG: Session {session.ticket_id} matches - Slot {slot.id} has parkinglot_id {slot.parkinglot_id}")
                else:
                    logger.debug(f"DEBUG: Session {session.ticket_id} doesn't match - Slot {slot.id if slot else 'None'} has parkinglot_id {slot.parkinglot_id if slot else 'None'}")
            else:
                logger.debug(f"DEBUG: Session {session.ticket_id} has no slot_id")
        
        logger.debug(f"DEBUG: Final filtered sessions: {len(sessions)}")
        
        # Format sessions data according to API specs
        sessions_data = []
        for session in sessions:
            # Get parkinglot_id from the slot relationship
            slot = Slot.query.filter_by(id=session.slot_id).first()
            parkinglot_id = slot.parkinglot_id if slot else None
            
            session_data = {
                "ticket_id": session.ticket_id,
                "parkinglot_id": parkinglot_id,
                "vehicle_reg_no": session.vehicle_reg_no,
                "user_id": session.user_id,
                "start_time": session.start_time.isoformat() + 'Z' if session.start_time else None,
                "end_time": session.end_time.isoformat() + 'Z' if session.end_time else None,
                "duration_hrs": float(session.duration_hrs) if session.duration_hrs else None,
                "vehicle_type": session.vehicle_type,
                "amount_paid": float(session.amount_paid) if session.amount_paid else 0,
            }

            sessions_data.append(session_data)
        
        logger.info(f"Successfully retrieved {len(sessions_data)} session details for admin_id: {admin_id}")
        return jsonify(sessions_data), 200
        
    except Exception as e:
        logger.exception(f"Failed to retrieve sessions for admin_id: {admin_id}")
        return jsonify({"error": f"Failed to retrieve sessions: {str(e)}"}), 500

@admin_bp.route('/debug/slots', methods=['GET'])
@role_required("admin")
def debug_slots():
    """
    Debug endpoint to check slot data
    """
    logger.debug(f"GET /admin/debug/slots called")
    try:
        # Get all slots
        slots = Slot.query.all()
        slot_data = []
        for slot in slots:
            slot_data.append({
                "slot_id": slot.id,
                "parkinglot_id": slot.parkinglot_id,
                "name": slot.name,
                "status": slot.status
            })
        
        logger.info(f"Successfully retrieved {len(slots)} slot details for debug")
        return jsonify({
            "total_slots": len(slots),
            "slots": slot_data
        }), 200
        
    except Exception as e:
        logger.exception(f"Debug failed: {str(e)}")
        return jsonify({"error": f"Debug failed: {str(e)}"}), 500

@admin_bp.route('/debug/sessions', methods=['GET'])
@role_required("admin")
def debug_admin_sessions():
    """
    Debug endpoint to check admin sessions data
    ---
    tags:
      - Admin
    description: |
      Debug endpoint to help troubleshoot admin sessions issues.
      Shows admin info, assigned lots, and session counts.
    responses:
      200:
        description: Debug information
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/debug/sessions called")
    try:
        # Get current user from JWT token
        current_user = get_current_user()
        admin_id = current_user["user_id"]
        
        # Get admin info
        admin = User.query.filter_by(user_id=admin_id, role='admin').first()
        if not admin:
            logger.warning(f"Admin not found with ID: {admin_id}")
            return jsonify({"error": "Admin not found"}), 404
        
        # Get admin's assigned lots
        admin_assignments = AdminParkingLot.query.filter_by(admin_id=admin_id).all()
        admin_lot_ids = [assignment.parking_lot_id for assignment in admin_assignments]
        
        # Get total sessions count
        total_sessions = ParkingSession.query.count()
        logger.debug(f"Total sessions in database: {total_sessions}")
        
        # Get sessions for admin's lots (all time) - join through Slot table
        admin_sessions_all_time = db.session.query(ParkingSession).join(
            Slot, ParkingSession.slot_id == Slot.id
        ).filter(
            Slot.parkinglot_id.in_(admin_lot_ids)
        ).count() if admin_lot_ids else 0
        logger.debug(f"Admin sessions in DB (all time): {admin_sessions_all_time}")
        
        # Get sessions for admin's lots (last 3 months) - join through Slot table
        three_months_ago = datetime.utcnow() - timedelta(days=90)
        admin_sessions_3_months = db.session.query(ParkingSession).join(
            Slot, ParkingSession.slot_id == Slot.id
        ).filter(
            Slot.parkinglot_id.in_(admin_lot_ids),
            ParkingSession.start_time >= three_months_ago
        ).count() if admin_lot_ids else 0
        logger.debug(f"Admin sessions in DB (last 3 months): {admin_sessions_3_months}")
        
        # Get sample sessions for debugging - join through Slot table
        sample_sessions = db.session.query(ParkingSession).join(
            Slot, ParkingSession.slot_id == Slot.id
        ).filter(
            Slot.parkinglot_id.in_(admin_lot_ids)
        ).limit(5).all() if admin_lot_ids else []
        
        sample_data = []
        for session in sample_sessions:
            # Get parkinglot_id from the slot relationship
            slot = Slot.query.filter_by(id=session.slot_id).first()
            parkinglot_id = slot.parkinglot_id if slot else None
            
            sample_data.append({
                "ticket_id": session.ticket_id,
                "parkinglot_id": parkinglot_id,
                "start_time": session.start_time.isoformat() + 'Z' if session.start_time else None,
                "user_id": session.user_id
            })
        
        logger.info(f"Successfully retrieved debug admin session information for admin_id: {admin_id}")
        return jsonify({
            "admin_info": {
                "admin_id": admin_id,
                "admin_name": admin.user_name,
                "admin_email": admin.user_email
            },
            "assigned_lots": admin_lot_ids,
            "session_counts": {
                "total_sessions_in_db": total_sessions,
                "admin_sessions_all_time": admin_sessions_all_time,
                "admin_sessions_3_months": admin_sessions_3_months
            },
            "sample_sessions": sample_data,
            "query_date_range": {
                "three_months_ago": three_months_ago.isoformat() + 'Z',
                "current_time": datetime.utcnow().isoformat() + 'Z'
            }
        }), 200
        
    except Exception as e:
        logger.exception(f"Debug failed: {str(e)}")
        return jsonify({"error": f"Debug failed: {str(e)}"}), 500

@admin_bp.route('/total_due', methods=['GET'])
@role_required("admin")
def get_total_due():
    """
    Get total due information for admin
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get outstanding amount and today's collection for the admin.
    responses:
      200:
        description: Total due information
        schema:
          type: object
          properties:
            date:
              type: string
              format: date
            outstanding_amount:
              type: number
            today_collection:
              type: number
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/total_due called")
    try:
        current_user = get_current_user()
        admin_id = current_user["user_id"]
        today = date_cls.today()
        logger.debug(f"Retrieved current user from JWT token: admin_id={admin_id}")
        
        # Get today's ledger entry
        today_ledger = AdminPaymentLedger.query.filter_by(
            admin_id=admin_id, 
            date=today
        ).first()
        
        # Get yesterday's closing balance (outstanding amount)
        yesterday_ledger = AdminPaymentLedger.query.filter(
            AdminPaymentLedger.admin_id == admin_id,
            AdminPaymentLedger.date < today
        ).order_by(AdminPaymentLedger.date.desc()).first()
        
        outstanding_amount = yesterday_ledger.closing_balance if yesterday_ledger else 0.0
        today_collection = today_ledger.today_collection if today_ledger else 0.0
        
        logger.info(f"Successfully retrieved total due information for admin_id: {admin_id}")
        return jsonify({
            "date": today.isoformat(),
            "outstanding_amount": float(outstanding_amount),
            "today_collection": float(today_collection)
        }), 200
        
    except Exception as e:
        logger.exception(f"Failed to retrieve total due for admin_id: {admin_id}")
        return jsonify({"error": f"Failed to retrieve total due: {str(e)}"}), 500

# @admin_bp.route('/finalize_closure', methods=['POST'])
# @role_required("admin")
# def finalize_closure():
#     """
#     Finalize closure for payment
#     ---
#     tags:
#       - Admin
#     description: |
#       Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
#       Admin submits the amount they are settling with.
#     parameters:
#       - in: body
#         name: body
#         required: true
#         schema:
#           type: object
#           required:
#             - payment_made
#           properties:
#             payment_made:
#               type: number
#     responses:
#       200:
#         description: Closure finalized successfully
#         schema:
#           type: object
#           properties:
#             new_outstanding:
#               type: number
#     security:
#       - Bearer: []
#     """
#     try:
#         current_user = get_current_user()
#         admin_id = current_user["user_id"]
#         data = request.get_json()
        
#         payment_made = data.get('payment_made', 0.0)
#         if payment_made < 0:
#             return jsonify({"error": "Payment amount cannot be negative"}), 400
        
#         today = date_cls.today()
        
#         # Get today's ledger entry
#         ledger = AdminPaymentLedger.query.filter_by(
#             admin_id=admin_id, 
#             date=today
#         ).first()
        
#         if not ledger:
#             return jsonify({"error": "No ledger entry found for today. Please check in some vehicles first."}), 400
        
#         # Get previous day's closing balance
#         prev_ledger = AdminPaymentLedger.query.filter(
#             AdminPaymentLedger.admin_id == admin_id,
#             AdminPaymentLedger.date < today
#         ).order_by(AdminPaymentLedger.date.desc()).first()
        
#         opening_balance = prev_ledger.closing_balance if prev_ledger else 0.0
        
#         # Calculate new outstanding balance
#         new_outstanding = opening_balance + ledger.today_collection - payment_made
        
#         # Update ledger with payment
#         ledger.payment_made = payment_made
#         ledger.closing_balance = new_outstanding
        
#         db.session.commit()
        
#         return jsonify({
#             "new_outstanding": float(new_outstanding)
#         }), 200
        
#     except Exception as e:
#         db.session.rollback()
#         return jsonify({"error": f"Failed to finalize closure: {str(e)}"}), 500

@admin_bp.route('/lot_admins/<int:lot_id>', methods=['GET'])
@role_required("admin")
def get_admins_for_lot(lot_id):
    """
    Get all admin IDs assigned to a parking lot
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get all admin IDs assigned to a parking lot.
    parameters:
      - in: path
        name: lot_id
        type: integer
        required: true
    responses:
      200:
        description: List of admin IDs for parking lot
    security:
      - Bearer: []
    """
    logger.debug(f"GET /admin/lot_admins/{lot_id} called")
    assignments = AdminParkingLot.query.filter_by(parking_lot_id=lot_id).all()
    admins = [a.admin_id for a in assignments]
    logger.info(f"Successfully retrieved admin IDs for parking lot_id: {lot_id}")
    return jsonify({'parking_lot_id': lot_id, 'admin_ids': admins}), 200

@admin_bp.route('/session/checkin', methods=['POST'])
@role_required("admin")
def vehicle_checkin():
    """
    Admin Vehicle Check-In (Allocate slot and start parking session)
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Admin Vehicle Check-In - Allocates a slot and starts a parking session.
      Follows the same format as user check-in but for admin use.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - vehicle_reg_no
            - slot_id
            - lot_id
            - vehicle_type
          properties:
            vehicle_reg_no:
              type: string
              description: "Vehicle registration number"
            slot_id:
              type: integer
              description: "Slot ID where vehicle will be parked"
            lot_id:
              type: integer
              description: "Parking lot ID where vehicle will be parked"
            vehicle_type:
              type: string
              description: "Type of vehicle (Car, Two-Wheeler, etc.)"
    responses:
      200:
        description: Vehicle checked in successfully
        schema:
          type: object
          properties:
            session_id:
              type: string
      400:
        description: Missing required fields or invalid input
      404:
        description: Slot not found or not available
      409:
        description: Slot occupied or vehicle already checked in
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    logger.debug(f"POST /admin/session/checkin called with data: {data}")
    
    vehicle_reg_no = data.get('vehicle_reg_no')
    slot_id = data.get('slot_id')
    lot_id = data.get('lot_id')
    vehicle_type = data.get('vehicle_type')
    
    # Validate required fields
    if not all([vehicle_reg_no, slot_id, lot_id, vehicle_type]):
        logger.warning(f"Missing required fields: vehicle_reg_no={bool(vehicle_reg_no)}, slot_id={bool(slot_id)}, lot_id={bool(lot_id)}, vehicle_type={bool(vehicle_type)}")
        return jsonify({
            "error": "vehicle_reg_no, slot_id, lot_id, and vehicle_type are required",
            "status": "failed"
        }), 400
    
    try:
        slot_id = int(slot_id)
        lot_id = int(lot_id)
        logger.debug(f"Converted parameters: slot_id={slot_id}, lot_id={lot_id}")
    except (ValueError, TypeError) as e:
        logger.error(f"Invalid parameter types: {str(e)}")
        return jsonify({
            "error": "slot_id and lot_id must be integers",
            "status": "failed"
        }), 400
    
    # Validate slot exists and is available
    slot = Slot.query.filter_by(id=slot_id, parkinglot_id=lot_id).first()
    if not slot:
        logger.warning(f"Slot not found with ID: {slot_id} in lot: {lot_id}")
        return jsonify({
            "error": "Slot not found",
            "status": "failed"
        }), 404
    
    if slot.status != 0:  # Slot is occupied
        logger.warning(f"Slot {slot_id} is already occupied")
        return jsonify({
            "error": "Slot is already occupied",
            "status": "failed"
        }), 409
    
    # Check if vehicle already has active session
    active_session = ParkingSession.query.filter_by(vehicle_reg_no=vehicle_reg_no, end_time=None).first()
    if active_session:
        logger.warning(f"Vehicle {vehicle_reg_no} already has active session: {active_session.ticket_id}")
        return jsonify({
            "error": "Vehicle already has an active parking session",
            "status": "failed"
        }), 409
    
    try:
        # Create new session
        ticket_id = str(uuid.uuid4())
        session = ParkingSession(
            ticket_id=ticket_id,
            parkinglot_id=lot_id,
            slot_id=slot_id,
            vehicle_reg_no=vehicle_reg_no,
            start_time=datetime.utcnow(),
            vehicle_type=vehicle_type
        )
        
        # Update slot status
        slot.status = 1  # Mark slot as occupied
        slot.vehicle_reg_no = vehicle_reg_no
        slot.ticket_id = ticket_id
        
        db.session.add(session)
        db.session.commit()
        
        logger.info(f"Vehicle check-in successful: ticket_id={ticket_id}, vehicle_reg_no={vehicle_reg_no}, slot_id={slot_id}")
        
        return jsonify({
            "session_id": ticket_id
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.exception(f"Check-in failed: {str(e)}")
        return jsonify({
            "error": f"Check-in failed: {str(e)}",
            "status": "failed"
        }), 500 

@admin_bp.route('/session/checkout', methods=['POST'])
@role_required("admin")
def vehicle_checkout():
    """
    Admin Vehicle Check-Out (Checkout and close active session)
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Admin Vehicle Check-Out - Checkout and close an active session.
      Follows the same format as user checkout but for admin use.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - vehicle_reg_no
          properties:
            vehicle_reg_no:
              type: string
              description: "Vehicle registration number to checkout"
    responses:
      200:
        description: Vehicle checked out successfully
        schema:
          type: object
          properties:
            amount_paid:
              type: number
            duration_hours:
              type: number
            checkout_time:
              type: string
              format: date-time
      400:
        description: Missing vehicle_reg_no
      404:
        description: No active session found for vehicle
    security:
      - Bearer: []
    """
    data = request.get_json() or {}
    logger.debug(f"POST /admin/session/checkout called with data: {data}")
    
    vehicle_reg_no = data.get('vehicle_reg_no')
    
    if not vehicle_reg_no:
        logger.warning("Missing vehicle_reg_no in checkout request")
        return jsonify({
            "error": "vehicle_reg_no is required",
            "status": "failed"
        }), 400
    
    try:
        # Find active session by vehicle_reg_no
        session = ParkingSession.query.filter_by(vehicle_reg_no=vehicle_reg_no, end_time=None).first()
        if not session:
            logger.warning(f"No active session found for vehicle: {vehicle_reg_no}")
            return jsonify({
                "error": "No active session found for this vehicle",
                "status": "failed"
            }), 404
        
        # Calculate duration
        now = datetime.utcnow()
        duration = now - session.start_time
        duration_hours = int(duration.total_seconds() // 3600)
        if duration.total_seconds() % 3600:
            duration_hours += 1  # round up to next hour
        
        # Get parking lot details for billing
        lot = ParkingLotDetails.query.filter_by(id=session.parkinglot_id).first()
        
        # Determine rate based on vehicle type
        if session.vehicle_type == 'Car':
            rate_str = lot.car_parking_charge if lot and lot.car_parking_charge else '20/hr'
        else:  # Two-Wheeler or default
            rate_str = lot.two_wheeler_parking_charge if lot and lot.two_wheeler_parking_charge else '10/hr'
        
        # Extract rate from string (e.g., "20/hr" -> 20)
        try:
            rate = float(rate_str.split('/')[0]) if rate_str else 20.0
        except:
            rate = 20.0  # Default rate
        
        amount_due = duration_hours * rate
        
        # Get slot details
        slot = Slot.query.filter_by(id=session.slot_id).first()
        
        # Update session
        session.end_time = now
        session.duration_hrs = duration_hours
        session.amount_paid = amount_due
        
        # Mark slot as available
        if slot:
            slot.status = 0
            slot.vehicle_reg_no = None
            slot.ticket_id = None
        
        # Update admin ledger
        admin_lots = AdminParkingLot.query.filter_by(parking_lot_id=session.parkinglot_id).all()
        if admin_lots:
            admin_id = admin_lots[0].admin_id
            today = date_cls.today()
            ledger = AdminPaymentLedger.query.filter_by(admin_id=admin_id, date=today).first()
            if not ledger:
                ledger = AdminPaymentLedger(
                    admin_id=admin_id,
                    date=today,
                    opening_balance=0.0,
                    today_collection=0.0,
                    payment_made=0.0,
                    closing_balance=0.0
                )
                db.session.add(ledger)
            
            ledger.today_collection += amount_due
        
        db.session.commit()
        
        logger.info(f"Vehicle checkout successful: vehicle_reg_no={vehicle_reg_no}, amount_due={amount_due}")
        return jsonify({
            "amount_paid": amount_due,
            "duration_hours": duration_hours,
            "checkout_time": session.end_time.isoformat() + 'Z'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        logger.exception(f"Checkout failed: {str(e)}")
        return jsonify({
            "error": f"Checkout failed: {str(e)}",
            "status": "failed"
        }), 500 

@admin_bp.route('/closure', methods=['POST'])
@role_required("admin")
def submit_daily_closure():
    """
    Submit daily closure/payment
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Submit daily closure/payment.
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            date:
              type: string
              description: YYYY-MM-DD
            payment_made:
              type: number
    responses:
      201:
        description: Closure submitted/updated
        schema:
          type: object
          properties:
            opening_balance:
              type: number
            today_collection:
              type: number
            payment_made:
              type: number
            closing_balance:
              type: number
      400:
        description: Invalid date format
    security:
      - Bearer: []
    """
    current_user = get_current_user()
    admin_id = current_user["user_id"]
    data = request.get_json()
    payment_made = data.get("payment_made", 0.0)
    entry_date = data.get("date")
    if entry_date:
        try:
            entry_date = date_cls.fromisoformat(entry_date)
        except Exception:
            logger.warning(f"Invalid date format provided: {entry_date}")
            return jsonify({"msg": "Invalid date format, use YYYY-MM-DD"}), 400
    else:
        entry_date = date_cls.today()
    logger.debug(f"POST /admin/closure called with data: {data}, admin_id={admin_id}, entry_date={entry_date}")
    
    # Get today's collection from ledger (should already be up-to-date from checkouts)
    ledger = AdminPaymentLedger.query.filter_by(admin_id=admin_id, date=entry_date).first()
    today_collection = ledger.today_collection if ledger else 0.0
    logger.debug(f"Today's collection for admin_id {admin_id} on {entry_date}: {today_collection}")
    
    # Get previous day's closing_balance
    prev_entry = AdminPaymentLedger.query.filter(AdminPaymentLedger.admin_id==admin_id, AdminPaymentLedger.date < entry_date).order_by(AdminPaymentLedger.date.desc()).first()
    opening_balance = prev_entry.closing_balance if prev_entry else 0.0
    logger.debug(f"Opening balance for admin_id {admin_id} on {entry_date}: {opening_balance}")
    
    closing_balance = opening_balance + today_collection - float(payment_made)
    logger.debug(f"Calculated closing balance for admin_id {admin_id} on {entry_date}: {closing_balance}")
    
    if not ledger:
        ledger = AdminPaymentLedger(
            admin_id=admin_id,
            date=entry_date,
            opening_balance=opening_balance,
            today_collection=today_collection,
            payment_made=payment_made,
            closing_balance=closing_balance
        )
        db.session.add(ledger)
        logger.info(f"Created new ledger entry for admin_id {admin_id} on {entry_date}")
    else:
        ledger.opening_balance = opening_balance
        ledger.payment_made = payment_made
        ledger.closing_balance = closing_balance
        logger.info(f"Updated existing ledger entry for admin_id {admin_id} on {entry_date}")
    db.session.commit()
    logger.info(f"Closure submitted/updated successfully for admin_id: {admin_id}, date: {entry_date}")
    return jsonify({
        "opening_balance": opening_balance,
        "today_collection": today_collection,
        "payment_made": float(payment_made),
        "closing_balance": closing_balance
    }), 201

@admin_bp.route('/closure', methods=['GET'])
@role_required("admin")
def get_closure_entries():
    """
    Get closure ledger entries for admin
    ---
    tags:
      - Admin
    description: |
      Note: You must use the Authorize button and provide a valid JWT as a Bearer token in the Authorization header.
      
      Get closure ledger entries for admin.
    parameters:
      - in: query
        name: start_date
        type: string
        required: false
      - in: query
        name: end_date
        type: string
        required: false
    responses:
      200:
        description: List of closure ledger entries
    security:
      - Bearer: []
    """
    current_user = get_current_user()
    admin_id = current_user["user_id"]
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")
    logger.debug(f"GET /admin/closure called with admin_id={admin_id}, start_date={start_date}, end_date={end_date}")
    
    query = AdminPaymentLedger.query.filter_by(admin_id=admin_id)
    if start_date:
        try:
            start_date = date_cls.fromisoformat(start_date)
            query = query.filter(AdminPaymentLedger.date >= start_date)
            logger.debug(f"Filtered by start_date: {start_date}")
        except Exception:
            logger.warning(f"Invalid start_date format provided: {start_date}")
            return jsonify({"msg": "Invalid start_date format, use YYYY-MM-DD"}), 400
    if end_date:
        try:
            end_date = date_cls.fromisoformat(end_date)
            query = query.filter(AdminPaymentLedger.date <= end_date)
            logger.debug(f"Filtered by end_date: {end_date}")
        except Exception:
            logger.warning(f"Invalid end_date format provided: {end_date}")
            return jsonify({"msg": "Invalid end_date format, use YYYY-MM-DD"}), 400
    entries = query.order_by(AdminPaymentLedger.date.desc()).all()
    logger.debug(f"Found {len(entries)} closure entries for admin_id: {admin_id}")
    result = [
        {
            "date": e.date.isoformat(),
            "opening_balance": e.opening_balance,
            "today_collection": e.today_collection,
            "payment_made": e.payment_made,
            "closing_balance": e.closing_balance
        }
        for e in entries
    ]
    logger.info(f"Successfully retrieved {len(result)} closure entries for admin_id: {admin_id}")
    return jsonify(result), 200 
