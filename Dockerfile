# Use official Python slim image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY app.py .
COPY requirements.txt .
COPY templates ./templates
COPY static ./static
COPY products.json .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variable for ELK host (replace with your container name if using docker-compose)
ENV ELK_HOST=logstash

# Expose Flask app port
EXPOSE 8777

# Start the Flask app
CMD ["python", "app.py"]
