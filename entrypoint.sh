#!/bin/bash

echo "Starting entrypoint script..."

# Create upload folder if it doesn't exist (redundant with Dockerfile, but kept for safety)
mkdir -p /app/app/static/uploads

# Function to check if MySQL is ready
# wait_for_mysql() {
#     echo "Waiting for MySQL to be ready..."
#     while ! nc -z ${DB_HOST:-db} ${DB_PORT:-3306}; do
#       sleep 1
#     done
#     echo "MySQL is ready!"
# }

# # Wait for MySQL to be ready
# wait_for_mysql

# Initialize the database
python << END
from init_db import init_db
init_db()
END

# Start the Flask application
echo "Starting Flask application..."

flask run --host=0.0.0.0