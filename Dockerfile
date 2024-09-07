FROM python:3.9-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    netcat \
    awscli \
    && rm -rf /var/lib/apt/lists/*

# Set up MariaDB directories
RUN mkdir -p /var/run/mysqld /var/lib/mysql /mnt/mysql-data \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /mnt/mysql-data \
    && chmod 777 /var/run/mysqld /mnt/mysql-data

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy application files
COPY . .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Expose port 5000 for the Flask app
EXPOSE 5000

ENV PROJECT_NAME=${PROJECT_NAME}

# Use the entrypoint script
CMD ["/bin/bash", "entrypoint.sh"]