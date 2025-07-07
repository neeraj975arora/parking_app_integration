import torch
import cv2
import psycopg2
import numpy as np
import pandas as pd
from ultralytics import YOLO

# Check if GPU is available
print("PyTorch GPU Available:", torch.cuda.is_available())

# Check OpenCV
print("OpenCV Version:", cv2.__version__)

# Load YOLOv5
model = YOLO("best.pt")
print("YOLO Model Loaded Successfully!")
