# 🚗 Parking Space Detection System

## 📌 Overview

This project is an AI-powered parking space detection system that leverages 

* OpenCV for parking spot identification
* YOLOv8 for vehicle detection. 
* The system processes a recorded video, detects parking spaces, determines whether they are occupied or empty, and updates the status in real time.


## 🛠️ How It Works?

The project consists of two main scripts, each playing a crucial role in the system:

### 1️⃣ get_parking_spot.py - Parking Spot Detection (OpenCV)

* Uses OpenCV to manually select and define parking spots from a given video input.

* The user marks parking slot coordinates by clicking on two opposite corners of each spot.

* The selected spots are then stored in a JSON file (parking_spots.json) for later use.

### 2️⃣ detect_parking_occupancy.py - Vehicle Detection & Parking Status (YOLOv8)

* Uses a pre-trained YOLOv8 model (best.pt) to detect vehicles in a recorded parking lot video.

* Loads the parking spot coordinates from parking_spots.json.

* Compares detected vehicles’ bounding boxes with predefined parking spots to determine occupied or empty spots.

* Outputs the results visually, where:

    -> **Red box** 🔴 → Occupied parking spot

    -> **Green box** 🟢 → Empty parking spot

    -> **Blue box** 🔵 → Vehicle type 


## 🚀 Installation & Setup

### 📌 Step 1: Clone the Repository
First, download the project from GitHub:


    git clone https://github.com/lakshitadanu/parking_detection_system.git
    cd parking_detection_system


### 📌 Step 2: Create a Virtual Environment (Recommended)
To avoid dependency conflicts, create and activate a virtual environment:    

**Create Virtual Environment**

    python3 -m venv venv  

**Activate Virtual Environment**
   
1. For Linux/Mac

        source venv/bin/activate 

2. For Windows (CMD)

        venv\Scripts\activate  

### 📌 Step 3: Install Dependencies     

Now, install the required Python libraries:

    pip install ultralytics torch torchvision torchaudio opencv-python numpy pandas psycopg2


Ensure that Ultralytics YOLOv8 and OpenCV are installed:

    pip install ultralytics opencv-python-headless

Then, verify the installation:

    python3 -c "import torch, cv2; print('PyTorch:', torch.cuda.is_available(), 'OpenCV:', cv2.__version__)"



### 📌 Step 4: Download YOLOv8 Model (best.pt)

 Ensure the trained YOLOv8 model **(best.pt)** is in the project directory. If missing, download it manually after training the Yolov8 model, and place it in the project directory.




### 📌 Step 5: Run the System

**1️⃣ Detect and Save Parking Spot Coordinates**

Run OpenCV-based parking slot detection:

    python3 get_parking_spot.py 

This will save parking slot coordinates in a JSON file.

**2️⃣ Detect Vehicles and Check Occupancy**

Run YOLOv8-based vehicle detection and occupancy check:

    python3 detect_parking_occupancy.py 

This will analyze the video and determine occupied/free slots.




