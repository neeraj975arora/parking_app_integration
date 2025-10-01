from flask import Blueprint, request, jsonify, current_app
from .models import Slot
from . import db
from .config import setup_logging
import logging

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)
logger.info("API v1 module initialized with centralized logging")

api_v1_bp = Blueprint('api_v1', __name__, url_prefix='/api/v1')

# Simple API Key Authentication
def require_api_key(f):
    def decorated_function(*args, **kwargs):
        logger.debug(f"API key authentication check for endpoint: {f.__name__}")
        api_key = request.headers.get('X-API-KEY')
        if not api_key or api_key != current_app.config.get('RPI_API_KEY'):
            logger.warning(f"Unauthorized API key access attempt from IP: {request.remote_addr}")
            return jsonify({"error": "Unauthorized"}), 401
        logger.info(f"API key authentication successful for endpoint: {f.__name__}")
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
    logger.debug(f"POST /api/v1/slots/update_status called with data: {data}")
    
    slot_id = data.get('id')
    new_status = data.get('status')

    if not slot_id or new_status is None:
        logger.warning(f"Missing required fields: slot_id={slot_id}, status={new_status}")
        return jsonify({"error": "Missing id or status"}), 400

    logger.debug(f"Looking up slot with ID: {slot_id}")
    slot = db.session.get(Slot, slot_id)
    if not slot:
        logger.warning(f"Slot not found with ID: {slot_id}")
        return jsonify({"error": "Slot not found"}), 404

    # Assuming status is an integer (e.g., 0 for free, 1 for occupied)
    try:
        old_status = slot.status
        slot.status = int(new_status)
        db.session.commit()
        logger.info(f"Slot {slot_id} status updated successfully from {old_status} to {new_status}")
        return jsonify({"message": f"Slot {slot_id} status updated to {new_status}"})
    except (ValueError, TypeError) as e:
        logger.error(f"Invalid status value: {new_status}, error: {str(e)}")
        return jsonify({"error": "Invalid status value"}), 400
    except Exception as e:
        db.session.rollback()
        logger.exception(f"Failed to update slot status: {str(e)}")
        return jsonify({"error": str(e)}), 500 