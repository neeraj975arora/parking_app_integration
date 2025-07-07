import os
import cv2
import json
import torch
import random
import numpy as np
from flask import Flask, send_file, render_template
from ultralytics import YOLO

# Configuration
VIDEO_PATH = "parking1.mp4"  # Video file path
MODEL_PATH = "best.pt"       # Your trained YOLO model
SPOTS_FILE = "parking_spots.json"  # JSON file with parking spot coordinates
OUTPUT_IMAGE = "static/output_frame.jpg"  # Output image

# Initialize Flask app
app = Flask(__name__)

# Load YOLO model
model = YOLO(MODEL_PATH)

def compute_iou(boxA, boxB):
    """Compute Intersection over Union (IoU) between two bounding boxes"""
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])

    # Compute intersection area
    interArea = max(0, xB - xA) * max(0, yB - yA)

    # Compute areas of both boxes
    boxAArea = (boxA[2] - boxA[0]) * (boxA[3] - boxA[1])
    boxBArea = (boxB[2] - boxB[0]) * (boxB[3] - boxB[1])

    # Compute IoU
    iou = interArea / float(boxAArea + boxBArea - interArea)
    return iou

@app.route("/")
def index():
    """Render the web UI"""
    return render_template("index.html", image_url=OUTPUT_IMAGE)

@app.route("/process")
def process_frame():
    """Processes one random frame and updates the output image"""
    # Load parking spots JSON
    with open(SPOTS_FILE, "r") as f:
        parking_spots = json.load(f)

    # Open video and select a random frame
    cap = cv2.VideoCapture(VIDEO_PATH)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    random_frame = random.randint(0, total_frames - 1)
    cap.set(cv2.CAP_PROP_POS_FRAMES, random_frame)

    ret, frame = cap.read()
    cap.release()

    if not ret:
        return "Error: Could not read frame from video", 500

    # Run YOLO detection on the full frame
    results = model.predict(frame, conf=0.5)
    detected_boxes = []

    # Extract YOLO detections
    for result in results:
        for box in result.boxes.xyxy:
            x1, y1, x2, y2 = map(int, box[:4])
            detected_boxes.append([x1, y1, x2, y2])

    # Process parking spots
    for spot_id, coords in parking_spots["parking1.mp4"].items():
        x1, y1, x2, y2 = coords["x1"], coords["y1"], coords["x2"], coords["y2"]
        spot_box = [x1, y1, x2, y2]

        occupied = False
        for detected_box in detected_boxes:
            iou = compute_iou(spot_box, detected_box)
            if iou > 0.3:  # Adjust IoU threshold as needed
                occupied = True
                break

        # Set colors based on occupancy
        color = (0, 0, 255) if occupied else (0, 255, 0)
        status = "Occupied" if occupied else "Empty"

        # Draw bounding boxes on the main frame
        cv2.rectangle(frame, (x1, y1), (x2, y2), color, 3)
        cv2.putText(frame, f"{spot_id}: {status}", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

    # Save processed image
    cv2.imwrite(OUTPUT_IMAGE, frame)

    return send_file(OUTPUT_IMAGE, mimetype="image/jpeg")

if __name__ == "__main__":
    os.makedirs("static", exist_ok=True)
    app.run(host="0.0.0.0", port=5000, debug=True)
