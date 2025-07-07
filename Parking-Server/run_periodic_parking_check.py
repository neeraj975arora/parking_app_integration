#!/usr/bin/env python
import os
import sys
from apscheduler.schedulers.background import BackgroundScheduler
import subprocess
import time
import requests
import json

# Activate venv if not already active
venv_path = os.path.join(os.path.dirname(__file__), 'venv', 'Scripts', 'activate_this.py')
if os.name == 'nt':
    venv_activate = os.path.join(os.path.dirname(__file__), 'venv', 'Scripts', 'activate_this.py')
else:
    venv_activate = os.path.join(os.path.dirname(__file__), 'venv', 'bin', 'activate_this.py')
if os.path.exists(venv_activate):
    with open(venv_activate) as f:
        exec(f.read(), {'__file__': venv_activate})

API_URL = "http://localhost:5000/api/v1/slots/update_status"
API_KEY = "super-secret-rpi-key"


def periodic_task():
    # Use the venv's python executable
    venv_python = os.path.join(os.path.dirname(__file__), 'venv', 'Scripts', 'python.exe')
    result = subprocess.run([venv_python, "detect_parking_occupancy.py"], capture_output=True, text=True)
    try:
        slot_statuses = json.loads(result.stdout)
    except Exception as e:
        print(f"Failed to parse output from detect_parking_occupancy.py: {e}")
        print(f"Raw output: {result.stdout}")
        return
    for slot in slot_statuses:
        payload = {"id": slot["id"], "status": slot["status"]}
        try:
            response = requests.post(
                API_URL,
                json=payload,
                headers={"X-API-KEY": API_KEY}
            )
            print(f"Updated slot {slot['id']} status to {slot['status']}: {response.status_code}")
        except Exception as e:
            print(f"Failed to update slot {slot['id']}: {e}")

if __name__ == "__main__":
    scheduler = BackgroundScheduler()
    scheduler.add_job(periodic_task, 'interval', minutes=2)
    scheduler.start()
    print("Scheduler started. Running detect_parking_occupancy.py every 2 minutes.")
    try:
        while True:
            time.sleep(60)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown() 