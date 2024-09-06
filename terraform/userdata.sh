#!/bin/bash

# Update the system
sudo yum update -y

# Install and configure Docker
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create a directory for the application
mkdir -p /app

# Create a docker-compose.yml file
cat << EOF > /app/docker-compose.yml
version: '3'
services:
  app:
    image: simonjan2/employee_management_flask_test:${app_version}
    ports:
      - "80:5000"
    restart: always
EOF

# Start the application
cd /app && docker-compose up -d

# Set up a cron job to check for updates every 5 minutes
echo "*/5 * * * * root cd /app && docker-compose pull && docker-compose up -d" | sudo tee -a /etc/crontab