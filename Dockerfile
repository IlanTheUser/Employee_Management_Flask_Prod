FROM python:3.9-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Set up MariaDB directories
RUN mkdir -p /var/run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
    && chmod 777 /var/run/mysqld

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

# Use the entrypoint script
CMD ["/bin/bash", "entrypoint.sh"]