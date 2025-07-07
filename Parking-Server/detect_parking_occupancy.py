import os
import sys
# Activate venv if not already active
venv_path = os.path.join(os.path.dirname(__file__), 'venv', 'Scripts', 'activate_this.py')
if os.name == 'nt':
    venv_activate = os.path.join(os.path.dirname(__file__), 'venv', 'Scripts', 'activate_this.py')
else:
    venv_activate = os.path.join(os.path.dirname(__file__), 'venv', 'bin', 'activate_this.py')
if os.path.exists(venv_activate):
    with open(venv_activate) as f:
        exec(f.read(), {'__file__': venv_activate})

import cv2
import json
import torch
import os
import requests
from ultralytics import YOLO

# Paths
MODEL_PATH = "best.pt"  # Path to trained YOLOv8 model
VIDEO_PATH = "parking1.mp4"  # Path to recorded parking video
JSON_PATH = "parking_spots.json"  # Path to saved parking spot coordinates

# Load YOLOv8 model
model = YOLO(MODEL_PATH)

# Load parking spot coordinates
if not os.path.exists(JSON_PATH):
    print(f"Error: {JSON_PATH} not found!")
    exit()

with open(JSON_PATH, "r") as f:
    parking_data = json.load(f)

# Extract parking spots for the given video
video_name = os.path.basename(VIDEO_PATH)
if video_name not in parking_data:
    print(f"Error: No parking spot data found for {video_name} in JSON file.")
    exit()

parking_spots = parking_data[video_name]  # Dictionary of parking spots
TOTAL_SPOTS = len(parking_spots)  # Total number of parking spots

# Open video and read a single frame
cap = cv2.VideoCapture(VIDEO_PATH)
cap.set(cv2.CAP_PROP_POS_MSEC, 0)  
ret, frame = cap.read()
if not ret:
    print("Error: Unable to read frame from video")
    cap.release()
    exit()

# Adjustable thresholds
IOU_THRESHOLD = 0.3  # Lowered IoU threshold for debugging
CONFIDENCE_THRESHOLD = 0.5  # Minimum confidence for vehicle detection

# Map spot names to slot IDs (dynamic for Spot_1, Spot_2, ...)
spot_name_to_id = {spot_name: int(spot_name.split('_')[1]) for spot_name in parking_spots.keys() if spot_name.startswith('Spot_') and spot_name.split('_')[1].isdigit()}

# Restore calculate_iou function
def calculate_iou(box1, box2):
    x1, y1, x2, y2 = box1
    x1_p, y1_p, x2_p, y2_p = box2
    inter_x1 = max(x1, x1_p)
    inter_y1 = max(y1, y1_p)
    inter_x2 = min(x2, x2_p)
    inter_y2 = min(y2, y2_p)
    inter_area = max(0, inter_x2 - inter_x1) * max(0, inter_y2 - inter_y1)
    box1_area = (x2 - x1) * (y2 - y1)
    box2_area = (x2_p - x1_p) * (y2_p - y1_p)
    union_area = box1_area + box2_area - inter_area
    return inter_area / union_area if union_area > 0 else 0

NUM_FRAMES = 10
FRAME_INTERVAL_MS = 500

# Initialize a dictionary to count occupied detections for each spot name
slot_occupancy_counts = {spot_name: 0 for spot_name in parking_spots.keys()}

for i in range(NUM_FRAMES):
    timestamp = 2000 + i * FRAME_INTERVAL_MS
    cap.set(cv2.CAP_PROP_POS_MSEC, timestamp)
    ret, frame = cap.read()
    if not ret:
        continue

    # Save original frame for reference
    cv2.imwrite(f"debug_frame_{i}.jpg", frame)

    # Prepare overlay frame
    analyzed_frame = frame.copy()

    # Run detection once per frame
    results = model(frame, verbose=False)
    vehicle_boxes = []
    for result in results:
        for box in result.boxes:
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            class_id = int(box.cls[0])
            conf = float(box.conf[0])
            if conf > CONFIDENCE_THRESHOLD:
                vehicle_boxes.append((x1, y1, x2, y2, class_id, conf))

    # For each spot, check occupancy, draw overlay, and increment count if occupied
    for spot_name, coords in parking_spots.items():
        x1, y1, x2, y2 = coords["x1"], coords["y1"], coords["x2"], coords["y2"]
        occupied = False
        for vx1, vy1, vx2, vy2, class_id, conf in vehicle_boxes:
            iou = calculate_iou((x1, y1, x2, y2), (vx1, vy1, vx2, vy2))
            if iou > IOU_THRESHOLD:
                occupied = True
                break
        slot_id = spot_name_to_id.get(spot_name, spot_name)  # fallback to name if no ID
        color = (0,0,255) if occupied else (0,255,0)  # Red for occupied, green for free
        cv2.rectangle(analyzed_frame, (x1, y1), (x2, y2), color, 2)
        cv2.putText(analyzed_frame, f"ID:{slot_id}", (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
        # Increment count if occupied
        if occupied:
            slot_occupancy_counts[spot_name] += 1
            #print(f"Frame {i}: {spot_name} marked occupied (IoU match)")

    # Add frame number
    cv2.putText(analyzed_frame, f"Frame {i}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (255,255,0), 2)

    # Calculate and overlay slot summary
    total_slots = len(parking_spots)
    occupied_count = sum(1 for spot in slot_occupancy_counts if slot_occupancy_counts[spot] > 0)
    available_count = total_slots - occupied_count
    summary_text = f"Total: {total_slots}  Occupied: {occupied_count}  Available: {available_count}"
    cv2.putText(analyzed_frame, summary_text, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255,255,255), 2)
    cv2.imwrite(f"debug_frame_{i}_analyzed.jpg", analyzed_frame)

# Mark as occupied if detected in at least 1 frame
slot_statuses = []
for spot_name in slot_occupancy_counts:
    slot_id = spot_name_to_id.get(spot_name, spot_name)  # fallback to name if no ID
    status = 1 if slot_occupancy_counts[spot_name] > 0 else 0
    slot_statuses.append({"id": slot_id, "status": status})

print(json.dumps(slot_statuses))
cap.release()
