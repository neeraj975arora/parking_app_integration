import cv2
import json
import os

# Define video path
video_path = r"F:\Education\Education\Impressico Internship\New folder\parking_detection_system\parking1.mp4"
video_name = os.path.basename(video_path)  # Extract filename (e.g., "parking1.mp4")

# Load the video
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print(f"Error: Unable to open video at {video_path}")
    exit()

# Read the first frame
ret, frame = cap.read()
cap.release()  # We only need the first frame

if not ret:
    print("Error: Could not read the first frame from the video.")
    exit()

# Copy the frame to allow rectangle drawing
clone = frame.copy()

# Store parking spot coordinates
parking_spots = []
click_count = 0  # Track click pairs

# Mouse click event handler
def select_parking_spot(event, x, y, flags, param):
    global parking_spots, click_count, clone

    if event == cv2.EVENT_LBUTTONDOWN:  # Left mouse click
        print(f"Clicked at: ({x}, {y})")

        if click_count % 2 == 0:
            parking_spots.append([(x, y)])  # Store first corner
        else:
            parking_spots[-1].append((x, y))  # Store second corner

            # Draw a rectangle on the frame
            cv2.rectangle(clone, parking_spots[-1][0], parking_spots[-1][1], (0, 255, 0), 2)
            cv2.imshow("Select Parking Spots", clone)

        click_count += 1

# Create a resizable window
cv2.namedWindow("Select Parking Spots", cv2.WINDOW_NORMAL)  # Allow resizing
cv2.resizeWindow("Select Parking Spots", 1000, 600)  # Set an initial window size
cv2.setWindowProperty("Select Parking Spots", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_NORMAL)  # Prevent fullscreen

# Display the frame
cv2.imshow("Select Parking Spots", frame)
cv2.setMouseCallback("Select Parking Spots", select_parking_spot)

# Wait until 'q' is pressed
print("Click on two opposite corners of each parking spot. Press 'q' when done.")
while True:
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):  # Press 'q' to exit
        break

# Print selected parking spots
for i, spot in enumerate(parking_spots):
    print(f"Parking Spot {i+1}: {spot}")

cv2.destroyAllWindows()

# Define JSON file path
json_file = r"F:\Education\Education\Impressico Internship\New folder\parking_detection_system\parking_spots.json"

# Load existing data (if any)
if os.path.exists(json_file):
    with open(json_file, "r") as f:
        try:
            parking_data = json.load(f)
        except json.JSONDecodeError:
            parking_data = {}  # If file is corrupted, start fresh
else:
    parking_data = {}

# Ensure that data for the current video is initialized
if video_name not in parking_data:
    parking_data[video_name] = {}

# Add new parking spots to the JSON structure
for i, (p1, p2) in enumerate(parking_spots):
    spot_name = f"Spot_{i+1}"
    parking_data[video_name][spot_name] = {
        "x1": p1[0], "y1": p1[1],
        "x2": p2[0], "y2": p2[1]
    }

# Save updated data to JSON (without overwriting existing entries)
with open(json_file, "w") as f:
    json.dump(parking_data, f, indent=4)

print(f"Parking spots saved to {json_file}")
