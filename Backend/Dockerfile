# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl

# Copy the requirements file into the container at /app
COPY app/requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project directory content into the container at /app
# This includes the 'app' package and 'wsgi.py'
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP wsgi.py

# Run the command to start gunicorn
# The working directory is /app, where wsgi.py and the app package are located
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"] 