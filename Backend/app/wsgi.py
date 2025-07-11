from create_app import create_app, db
from models import User, ParkingLotDetails, Floor, Row, Slot, ParkingSession
import os

app = create_app(os.getenv('FLASK_CONFIG') or 'default')

@app.shell_context_processor
def make_shell_context():
    return dict(
        db=db,
        User=User,
        ParkingLotDetails=ParkingLotDetails,
        Floor=Floor,
        Row=Row,
        Slot=Slot,
        ParkingSession=ParkingSession
    )
