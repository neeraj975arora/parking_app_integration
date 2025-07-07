from flask import Blueprint, request, jsonify, current_app
from .models import Slot
from . import db

api_v1_bp = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Simple API Key Authentication
def require_api_key(f):
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-KEY')
        if not api_key or api_key != current_app.config.get('RPI_API_KEY'):
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return decorated_function

@api_v1_bp.route('/slots/update_status', methods=['POST'])
@require_api_key
def update_slot_status():
    """
    Update the status of a parking slot. (For RPi clients)
    ---
    tags:
      - RPi API
    security:
      - ApiKey: []
    parameters:
      - in: body
        name: body
        schema:
          type: object
          required:
            - id
            - status
          properties:
            id:
              type: integer
            status:
              type: integer
              description: "0 for free, 1 for occupied"
    responses:
      200:
        description: Slot status updated successfully
      400:
        description: Invalid input
      401:
        description: Unauthorized
      404:
        description: Slot not found
    """
    data = request.get_json()
    slot_id = data.get('id')
    new_status = data.get('status')

    if not slot_id or new_status is None:
        return jsonify({"error": "Missing id or status"}), 400

    slot = db.session.get(Slot, slot_id)
    if not slot:
        return jsonify({"error": "Slot not found"}), 404

    # Assuming status is an integer (e.g., 0 for free, 1 for occupied)
    try:
        slot.status = int(new_status)
        db.session.commit()
        return jsonify({"message": f"Slot {slot_id} status updated to {new_status}"})
    except (ValueError, TypeError):
        return jsonify({"error": "Invalid status value"}), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500 