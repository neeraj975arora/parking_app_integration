from flask import Blueprint, request, jsonify
from .models import ParkingLotDetails, Floor, Row, Slot
from . import db, ma
from flask_jwt_extended import jwt_required
from marshmallow import post_load
from .admin import role_required

# Marshmallow Schemas
class SlotSchema(ma.Schema):
    id = ma.Int(dump_only=True)
    name = ma.Str(required=True)
    status = ma.Int()
    vehicle_reg_no = ma.Str()
    ticket_id = ma.Str()
    row_id = ma.Int(load_only=True, required=True)
    floor_id = ma.Int(load_only=True, required=True)
    parkinglot_id = ma.Int(load_only=True, required=True)

    @post_load
    def make_slot(self, data, **kwargs):
        return Slot(**data)

class RowSchema(ma.Schema):
    id = ma.Int(dump_only=True)
    name = ma.Str(required=True)
    floor_id = ma.Int(load_only=True, required=True)
    parkinglot_id = ma.Int(load_only=True, required=True)
    slots = ma.Nested(SlotSchema, many=True, dump_only=True)

    @post_load
    def make_row(self, data, **kwargs):
        return Row(**data)

class FloorSchema(ma.Schema):
    id = ma.Int(dump_only=True)
    name = ma.Str(required=True)
    parkinglot_id = ma.Int(load_only=True, required=True)
    rows = ma.Nested(RowSchema, many=True, dump_only=True)

    @post_load
    def make_floor(self, data, **kwargs):
        return Floor(**data)

class ParkingLotDetailsSchema(ma.Schema):
    id = ma.Int(dump_only=True)
    name = ma.Str(required=True)
    city = ma.Str()
    landmark = ma.Str()
    address = ma.Str(required=True)
    latitude = ma.Float()
    longitude = ma.Float()
    physical_appearance = ma.Str()
    parking_ownership = ma.Str()
    parking_surface = ma.Str()
    has_cctv = ma.Str()
    has_boom_barrier = ma.Str()
    ticket_generated = ma.Str()
    entry_exit_gates = ma.Str()
    weekly_off = ma.Str()
    parking_timing = ma.Str()
    vehicle_types = ma.Str()
    car_capacity = ma.Int()
    available_car_slots = ma.Int()
    two_wheeler_capacity = ma.Int()
    available_two_wheeler_slots = ma.Int()
    parking_type = ma.Str()
    payment_modes = ma.Str()
    car_parking_charge = ma.Str()
    two_wheeler_parking_charge = ma.Str()
    allows_prepaid_passes = ma.Str()
    provides_valet_services = ma.Str()
    value_added_services = ma.Str()
    opening_time = ma.Time()
    closing_time = ma.Time()
    total_floors = ma.Int()
    total_rows = ma.Int()
    total_slots = ma.Int()
    created_at = ma.DateTime(dump_only=True)
    updated_at = ma.DateTime(dump_only=True)
    floors = ma.Nested(FloorSchema, many=True, dump_only=True)

    @post_load
    def make_parking_lot(self, data, **kwargs):
        return ParkingLotDetails(**data)

# Schema for list view (without nested details)
parking_lot_summary_schema = ParkingLotDetailsSchema(exclude=("floors",))
parking_lots_summary_schema = ParkingLotDetailsSchema(many=True, exclude=("floors",))

# Schema for detail view (with all nested details)
parking_lot_detail_schema = ParkingLotDetailsSchema()

slot_schema = SlotSchema()
slots_schema = SlotSchema(many=True)
row_schema = RowSchema()
rows_schema = RowSchema(many=True)
floor_schema = FloorSchema()
floors_schema = FloorSchema(many=True)

parking_bp = Blueprint('parking', __name__, url_prefix='/parking')

@parking_bp.route('/lots', methods=['POST'])
@role_required("user")
def create_parking_lot():
    """Create a new parking lot."""
    data = request.get_json()
    try:
        new_lot = parking_lot_summary_schema.load(data)
        db.session.add(new_lot)
        db.session.commit()
        return jsonify(parking_lot_summary_schema.dump(new_lot)), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/lots', methods=['GET'])
@role_required("user")
def get_parking_lots():
    """Get a list of all parking lots (summary view)."""
    lots = ParkingLotDetails.query.all()
    return jsonify(parking_lots_summary_schema.dump(lots))

@parking_bp.route('/lots/<int:lot_id>', methods=['GET'])
@role_required("user")
def get_parking_lot(lot_id):
    """Get detailed information about a specific parking lot, including nested floors, rows, and slots."""
    lot = db.session.get(ParkingLotDetails, lot_id)
    if not lot:
        return jsonify({"error": "Parking lot not found"}), 404
    return jsonify(parking_lot_detail_schema.dump(lot))

@parking_bp.route('/lots/<int:lot_id>/stats', methods=['GET'])
@role_required("user")
def get_parking_lot_stats(lot_id):
    """Get statistics (total, occupied, available slots) for a specific parking lot."""
    if not db.session.get(ParkingLotDetails, lot_id):
        return jsonify({"error": "Parking lot not found"}), 404

    total_slots = Slot.query.filter_by(parkinglot_id=lot_id).count()
    available_slots = Slot.query.filter_by(parkinglot_id=lot_id, status=0).count()
    occupied_slots = total_slots - available_slots

    stats = {
        'parkinglot_id': lot_id,
        'total_slots': total_slots,
        'available_slots': available_slots,
        'occupied_slots': occupied_slots
    }
    return jsonify(stats)

@parking_bp.route('/lots/<int:lot_id>', methods=['PUT'])
@role_required("user")
def update_parking_lot(lot_id):
    """Update a parking lot's details."""
    lot = db.session.get(ParkingLotDetails, lot_id)
    if not lot:
        return jsonify({"error": "Parking lot not found"}), 404
    
    data = request.get_json()
    try:
        updated_lot = parking_lot_summary_schema.load(data, instance=lot, partial=True)
        db.session.commit()
        return jsonify(parking_lot_summary_schema.dump(updated_lot))
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/lots/<int:lot_id>', methods=['DELETE'])
@role_required("user")
def delete_parking_lot(lot_id):
    """Delete a parking lot."""
    lot = db.session.get(ParkingLotDetails, lot_id)
    if not lot:
        return jsonify({"error": "Parking lot not found"}), 404
    
    db.session.delete(lot)
    db.session.commit()
    return jsonify({"message": "Parking lot deleted successfully"})

# Floor CRUD Endpoints
@parking_bp.route('/lots/<int:lot_id>/floors', methods=['POST'])
@role_required("user")
def create_floor(lot_id):
    """Create a new floor within a parking lot."""
    if not db.session.get(ParkingLotDetails, lot_id):
        return jsonify({"error": "Parking lot not found"}), 404
        
    data = request.get_json()
    data['parkinglot_id'] = lot_id
    try:
        new_floor = floor_schema.load(data)
        db.session.add(new_floor)
        db.session.commit()
        return jsonify(floor_schema.dump(new_floor)), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/lots/<int:lot_id>/floors', methods=['GET'])
@role_required("user")
def get_floors_for_lot(lot_id):
    """Get all floors for a specific parking lot."""
    lot = db.session.get(ParkingLotDetails, lot_id)
    if not lot:
        return jsonify({"error": "Parking lot not found"}), 404
    return jsonify(floors_schema.dump(lot.floors))

@parking_bp.route('/floors/<int:floor_id>', methods=['GET'])
@role_required("user")
def get_floor(floor_id):
    """Get details of a specific floor."""
    floor = db.session.get(Floor, floor_id)
    if not floor:
        return jsonify({"error": "Floor not found"}), 404
    return jsonify(floor_schema.dump(floor))

@parking_bp.route('/floors/<int:floor_id>', methods=['PUT'])
@role_required("user")
def update_floor(floor_id):
    """Update a floor's details."""
    floor = db.session.get(Floor, floor_id)
    if not floor:
        return jsonify({"error": "Floor not found"}), 404
    
    data = request.get_json()
    try:
        updated_floor = floor_schema.load(data, instance=floor, partial=True)
        db.session.commit()
        return jsonify(floor_schema.dump(updated_floor))
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/floors/<int:floor_id>', methods=['DELETE'])
@role_required("user")
def delete_floor(floor_id):
    """Delete a floor."""
    floor = db.session.get(Floor, floor_id)
    if not floor:
        return jsonify({"error": "Floor not found"}), 404
    
    db.session.delete(floor)
    db.session.commit()
    return jsonify({"message": "Floor deleted successfully"})

# Row CRUD Endpoints
@parking_bp.route('/floors/<int:floor_id>/rows', methods=['POST'])
@role_required("user")
def create__row(floor_id):
    """Create a new row within a floor."""
    floor = db.session.get(Floor, floor_id)
    if not floor:
        return jsonify({"error": "Floor not found"}), 404
        
    data = request.get_json()
    data['floor_id'] = floor_id
    data['parkinglot_id'] = floor.parkinglot_id
    try:
        new_row = row_schema.load(data)
        db.session.add(new_row)
        db.session.commit()
        return jsonify(row_schema.dump(new_row)), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/floors/<int:floor_id>/rows', methods=['GET'])
@role_required("user")
def get_rows_for_floor(floor_id):
    """Get all rows for a specific floor."""
    floor = db.session.get(Floor, floor_id)
    if not floor:
        return jsonify({"error": "Floor not found"}), 404
    return jsonify(rows_schema.dump(floor.rows))

@parking_bp.route('/rows/<int:row_id>', methods=['GET'])
@role_required("user")
def get_row(row_id):
    """Get details of a specific row."""
    row = db.session.get(Row, row_id)
    if not row:
        return jsonify({"error": "Row not found"}), 404
    return jsonify(row_schema.dump(row))

@parking_bp.route('/rows/<int:row_id>', methods=['PUT'])
@role_required("user")
def update_row(row_id):
    """Update a row's details."""
    row = db.session.get(Row, row_id)
    if not row:
        return jsonify({"error": "Row not found"}), 404
    
    data = request.get_json()
    try:
        updated_row = row_schema.load(data, instance=row, partial=True)
        db.session.commit()
        return jsonify(row_schema.dump(updated_row))
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/rows/<int:row_id>', methods=['DELETE'])
@role_required("user")
def delete_row(row_id):
    """Delete a row."""
    row = db.session.get(Row, row_id)
    if not row:
        return jsonify({"error": "Row not found"}), 404
    
    db.session.delete(row)
    db.session.commit()
    return jsonify({"message": "Row deleted successfully"})

# Slot CRUD Endpoints
@parking_bp.route('/rows/<int:row_id>/slots', methods=['POST'])
@role_required("user")
def create_slot(row_id):
    """Create a new slot within a row."""
    row = db.session.get(Row, row_id)
    if not row:
        return jsonify({"error": "Row not found"}), 404

    data = request.get_json()
    data['row_id'] = row_id
    data['floor_id'] = row.floor_id
    data['parkinglot_id'] = row.parkinglot_id
    try:
        new_slot = slot_schema.load(data)
        db.session.add(new_slot)
        db.session.commit()
        return jsonify(slot_schema.dump(new_slot)), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/rows/<int:row_id>/slots', methods=['GET'])
@role_required("user")
def get_slots_for_row(row_id):
    """Get all slots for a specific row."""
    row = db.session.get(Row, row_id)
    if not row:
        return jsonify({"error": "Row not found"}), 404
    return jsonify(slots_schema.dump(row.slots))

@parking_bp.route('/slots/<int:slot_id>', methods=['GET'])
@role_required("user")
def get_slot(slot_id):
    """Get details of a specific slot."""
    slot = db.session.get(Slot, slot_id)
    if not slot:
        return jsonify({"error": "Slot not found"}), 404
    return jsonify(slot_schema.dump(slot))

@parking_bp.route('/slots/<int:slot_id>', methods=['PUT'])
@role_required("user")
def update_slot(slot_id):
    """Update a slot's details."""
    slot = db.session.get(Slot, slot_id)
    if not slot:
        return jsonify({"error": "Slot not found"}), 404
    
    data = request.get_json()
    try:
        updated_slot = slot_schema.load(data, instance=slot, partial=True)
        db.session.commit()
        return jsonify(slot_schema.dump(updated_slot))
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 400

@parking_bp.route('/slots/<int:slot_id>', methods=['DELETE'])
@role_required("user")
def delete_slot(slot_id):
    """Delete a slot."""
    slot = db.session.get(Slot, slot_id)
    if not slot:
        return jsonify({"error": "Slot not found"}), 404
    
    db.session.delete(slot)
    db.session.commit()
    return jsonify({"message": "Slot deleted successfully"})