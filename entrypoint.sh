#!/bin/bash

echo "Starting entrypoint script..."

# Export the PROJECT_NAME environment variable
export PROJECT_NAME=${PROJECT_NAME}

# Check if the MySQL data directory exists
if [ ! -d "/mnt/mysql-data" ]; then
    echo "Error: MySQL data directory /mnt/mysql-data does not exist"
    exit 1
fi

# Check permissions of the MySQL data directory
echo "Checking MySQL data directory permissions..."
ls -l /mnt/mysql-data

# Start MariaDB using the new data directory
echo "Starting MariaDB..."
mysqld_safe --datadir=/mnt/mysql-data &

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
for i in {1..30}; do
    if mysqladmin ping -h"localhost" --silent; then
        echo "MariaDB is ready!"
        break
    fi
    echo "Attempt $i: MariaDB not ready yet..."
    sleep 2
done

if ! mysqladmin ping -h"localhost" --silent; then
    echo "Error: MariaDB failed to start after 60 seconds"
    echo "MariaDB error log:"
    cat /var/log/mysql/error.log
    exit 1
fi

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
mysql -e "CREATE DATABASE IF NOT EXISTS employee_management;"
mysql -e "CREATE USER IF NOT EXISTS 'user'@'localhost' IDENTIFIED BY 'password';"
mysql -e "GRANT ALL PRIVILEGES ON employee_management.* TO 'user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create upload folder if it doesn't exist
echo "Creating upload folder..."
mkdir -p /app/app/static/uploads

# Initialize the database
echo "Initializing database..."
python -c "from app import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"
echo "Database initialized!"

# Start the Flask application
echo "Starting Flask application..."
flask run --host=0.0.0.0