FROM python:3.9-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    netcat \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy application files
COPY . .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Create upload folder
RUN mkdir -p /app/app/static/uploads

# Expose port 5000 for the Flask app
EXPOSE 5000

# Use the entrypoint script
CMD ["/bin/bash", "entrypoint.sh"]