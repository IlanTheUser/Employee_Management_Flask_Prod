#!/bin/bash

echo "Starting entrypoint script..."

# Start MariaDB using mysqld_safe
echo "Starting MariaDB..."
mysqld_safe &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 1
done
echo "MariaDB is ready!"

# Create database if it doesn't exist
mysql -e "CREATE DATABASE IF NOT EXISTS employee_management;"
mysql -e "CREATE USER IF NOT EXISTS 'user'@'localhost' IDENTIFIED BY 'password';"
mysql -e "GRANT ALL PRIVILEGES ON employee_management.* TO 'user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create upload folder if it doesn't exist
mkdir -p /app/app/static/uploads

# Initialize the database
echo "Initializing database..."
python -c "from app import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"
echo "Database initialized!"

# Start the Flask application
echo "Starting Flask application..."
flask run --host=0.0.0.0