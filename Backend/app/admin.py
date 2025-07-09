import jwt
from flask import Blueprint, request, jsonify, current_app
from functools import wraps
from .models import db, User, ParkingLotDetails, AdminParkingLot, Slot, ParkingSession, AdminPaymentLedger
import uuid
from datetime import datetime
from sqlalchemy import and_
from datetime import date as date_cls

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

# Helper: Only allow super-admin/system for assignment (for now, allow all for demo)
def is_super_admin():
    # Placeholder: In production, check for a real super-admin role/claim
    return True

def decode_token(token):
    try:
        secret = current_app.config.get('SECRET_KEY', 'dev_secret')
        payload = jwt.decode(token, secret, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        raise Exception("Token expired")
    except jwt.InvalidTokenError:
        raise Exception("Invalid token")

def role_required(required_role):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            auth_header = request.headers.get("Authorization")
            if not auth_header or not auth_header.startswith("Bearer "):
                return jsonify({"error": "Missing or invalid token"}), 401
            token = auth_header.split(" ")[1]
            try:
                payload = decode_token(token)
                user_role = payload["role"]
                if required_role == "admin":
                    if user_role not in ["admin", "super_admin"]:
                        return jsonify({"error": "Forbidden: insufficient role"}), 403
                elif required_role == "super_admin":
                    if user_role != "super_admin":
                        return jsonify({"error": "Forbidden: insufficient role"}), 403
                else:
                    if user_role != required_role:
                        return jsonify({"error": "Forbidden: insufficient role"}), 403
            except Exception as e:
                return jsonify({"error": str(e)}), 401
            return f(*args, **kwargs)
        return wrapper
    return decorator

@admin_bp.route('/assign_lot', methods=['POST'])
@role_required("super_admin")
def assign_lot_to_admin():
    data = request.get_json()
    admin_id = data.get('admin_id')
    lot_id = data.get('parking_lot_id')
    # Validate admin exists and is an admin
    admin = User.query.filter_by(user_id=admin_id, role='admin').first()
    lot = ParkingLotDetails.query.filter_by(id=lot_id).first()
    if not admin or not lot:
        return jsonify({'msg': 'Invalid admin or parking lot'}), 400
    # Enforce only one admin per lot
    existing_assignment = AdminParkingLot.query.filter_by(parking_lot_id=lot_id).first()
    if existing_assignment:
        return jsonify({'msg': 'This parking lot is already assigned to an admin'}), 409
    assignment = AdminParkingLot(admin_id=admin_id, parking_lot_id=lot_id)
    db.session.add(assignment)
    db.session.commit()
    return jsonify({'msg': 'Parking lot assigned to admin'}), 201

@admin_bp.route('/remove_assignment', methods=['DELETE'])
@role_required("super_admin")
def remove_assignment():
    data = request.get_json()
    admin_id = data.get('admin_id')
    lot_id = data.get('parking_lot_id')
    assignment = AdminParkingLot.query.filter_by(admin_id=admin_id, parking_lot_id=lot_id).first()
    if not assignment:
        return jsonify({'msg': 'Assignment not found'}), 404
    db.session.delete(assignment)
    db.session.commit()
    return jsonify({'msg': 'Assignment removed'}), 200

@admin_bp.route('/admin_lots/<int:admin_id>', methods=['GET'])
@role_required("admin")
def get_lots_for_admin(admin_id):
    assignments = AdminParkingLot.query.filter_by(admin_id=admin_id).all()
    lots = [a.parking_lot_id for a in assignments]
    return jsonify({'admin_id': admin_id, 'parking_lot_ids': lots}), 200

@admin_bp.route('/lot_admins/<int:lot_id>', methods=['GET'])
@role_required("admin")
def get_admins_for_lot(lot_id):
    assignments = AdminParkingLot.query.filter_by(parking_lot_id=lot_id).all()
    admins = [a.admin_id for a in assignments]
    return jsonify({'parking_lot_id': lot_id, 'admin_ids': admins}), 200

@admin_bp.route('/session/checkin', methods=['POST'])
@role_required("admin")
def vehicle_checkin():
    data = request.get_json()
    vehicle_reg_no = data.get('vehicle_reg_no')
    slot_id = data.get('slot_id')
    lot_id = data.get('lot_id')
    vehicle_type = data.get('vehicle_type')
    if not all([vehicle_reg_no, slot_id, lot_id, vehicle_type]):
        return jsonify({'msg': 'Missing required fields'}), 400
    # Validate slot and lot
    slot = Slot.query.filter_by(id=slot_id, parkinglot_id=lot_id).first()
    if not slot:
        return jsonify({'msg': 'Slot or lot not found'}), 404
    if slot.status == 1:
        return jsonify({'msg': 'Slot is already occupied'}), 409
    # Check for active session for this vehicle
    active_session = ParkingSession.query.filter_by(vehicle_reg_no=vehicle_reg_no, end_time=None).first()
    if active_session:
        return jsonify({'msg': 'Vehicle already checked in'}), 409
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
    slot.status = 1  # Mark slot as occupied
    slot.vehicle_reg_no = vehicle_reg_no
    slot.ticket_id = ticket_id
    db.session.add(session)
    db.session.commit()
    return jsonify({'msg': 'Vehicle checked in', 'session_id': ticket_id}), 200 

@admin_bp.route('/session/checkout', methods=['POST'])
@role_required("admin")
def vehicle_checkout():
    data = request.get_json()
    vehicle_reg_no = data.get('vehicle_reg_no')
    if not vehicle_reg_no:
        return jsonify({'msg': 'Missing vehicle_reg_no'}), 400
    # Find active session
    session = ParkingSession.query.filter_by(vehicle_reg_no=vehicle_reg_no, end_time=None).first()
    if not session:
        return jsonify({'msg': 'No active session found for this vehicle'}), 404
    # Calculate duration
    now = datetime.utcnow()
    duration = now - session.start_time
    duration_hours = int(duration.total_seconds() // 3600)
    if duration.total_seconds() % 3600:
        duration_hours += 1  # round up to next hour
    # Determine rate
    lot = ParkingLotDetails.query.filter_by(id=session.parkinglot_id).first()
    if not lot:
        return jsonify({'msg': 'Parking lot not found'}), 404
    # Parse rate from lot fields
    if session.vehicle_type and session.vehicle_type.lower() == 'car':
        rate_str = getattr(lot, 'car_parking_charge', '0')
    else:
        rate_str = getattr(lot, 'two_wheeler_parking_charge', '0')
    try:
        rate = float(rate_str.split('/')[0])
    except Exception:
        rate = 0.0
    amount_paid = duration_hours * rate
    # Update session
    session.end_time = now
    session.duration_hrs = duration_hours
    session.amount_paid = amount_paid
    # Mark slot as available
    slot = Slot.query.filter_by(id=session.slot_id).first()
    if slot:
        slot.status = 0
        slot.vehicle_reg_no = None
        slot.ticket_id = None
    # --- Update admin ledger ---
    admin_lots = AdminParkingLot.query.filter_by(parking_lot_id=session.parkinglot_id).all()
    if len(admin_lots) == 0:
        return jsonify({'msg': 'No admin assigned to this parking lot'}), 400
    if len(admin_lots) > 1:
        return jsonify({'msg': 'Multiple admins assigned to this parking lot, which is not allowed'}), 400
    admin_id = admin_lots[0].admin_id
    today = date_cls.today()
    ledger = AdminPaymentLedger.query.filter_by(admin_id=admin_id, date=today).first()
    if not ledger:
        ledger = AdminPaymentLedger(
            admin_id=admin_id,
            date=today,
            opening_balance=0.0,  # Will be set at closure
            today_collection=0.0,
            payment_made=0.0,
            closing_balance=0.0
        )
        db.session.add(ledger)
    ledger.today_collection += amount_paid
    db.session.commit()
    return jsonify({
        'amount_paid': amount_paid,
        'duration_hours': duration_hours,
        'checkout_time': now.isoformat() + 'Z'
    }), 200 

@admin_bp.route('/closure', methods=['POST'])
@role_required("admin")
def submit_daily_closure():
    payload = decode_token(request.headers.get("Authorization").split(" ")[1])
    admin_id = payload["user_id"]
    data = request.get_json()
    payment_made = data.get("payment_made", 0.0)
    entry_date = data.get("date")
    if entry_date:
        try:
            entry_date = date_cls.fromisoformat(entry_date)
        except Exception:
            return jsonify({"msg": "Invalid date format, use YYYY-MM-DD"}), 400
    else:
        entry_date = date_cls.today()
    # Get today's collection from ledger (should already be up-to-date from checkouts)
    ledger = AdminPaymentLedger.query.filter_by(admin_id=admin_id, date=entry_date).first()
    today_collection = ledger.today_collection if ledger else 0.0
    # Get previous day's closing_balance
    prev_entry = AdminPaymentLedger.query.filter(AdminPaymentLedger.admin_id==admin_id, AdminPaymentLedger.date < entry_date).order_by(AdminPaymentLedger.date.desc()).first()
    opening_balance = prev_entry.closing_balance if prev_entry else 0.0
    closing_balance = opening_balance + today_collection - float(payment_made)
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
    else:
        ledger.opening_balance = opening_balance
        ledger.payment_made = payment_made
        ledger.closing_balance = closing_balance
    db.session.commit()
    return jsonify({
        "opening_balance": opening_balance,
        "today_collection": today_collection,
        "payment_made": float(payment_made),
        "closing_balance": closing_balance
    }), 201

@admin_bp.route('/closure', methods=['GET'])
@role_required("admin")
def get_closure_entries():
    payload = decode_token(request.headers.get("Authorization").split(" ")[1])
    admin_id = payload["user_id"]
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")
    query = AdminPaymentLedger.query.filter_by(admin_id=admin_id)
    if start_date:
        try:
            start_date = date_cls.fromisoformat(start_date)
            query = query.filter(AdminPaymentLedger.date >= start_date)
        except Exception:
            return jsonify({"msg": "Invalid start_date format, use YYYY-MM-DD"}), 400
    if end_date:
        try:
            end_date = date_cls.fromisoformat(end_date)
            query = query.filter(AdminPaymentLedger.date <= end_date)
        except Exception:
            return jsonify({"msg": "Invalid end_date format, use YYYY-MM-DD"}), 400
    entries = query.order_by(AdminPaymentLedger.date.desc()).all()
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
    return jsonify(result), 200 