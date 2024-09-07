#!/bin/bash

# Update the system
sudo yum update -y

# Install and configure Docker
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# Mount EBS volume
sudo mkfs -t ext4 /dev/xvdh
sudo mkdir -p /mnt/mysql-data
sudo mount /dev/xvdh /mnt/mysql-data
sudo chown -R 999:999 /mnt/mysql-data  # 999 is typically the mysql user in Docker

# Check if the MySQL data directory is empty
if [ -z "$(ls -A /mnt/mysql-data)" ]; then
    echo "MySQL data directory is empty. Initializing with default MySQL data..."
    sudo docker run --rm -v /mnt/mysql-data:/var/lib/mysql mysql:5.7 /bin/bash -c "mysqld --initialize-insecure"
fi

# Pull and run the Docker image
sudo docker pull simonjan2/employee_management_flask_test:${app_version}
sudo docker run -d -p 80:5000 -v /mnt/mysql-data:/mnt/mysql-data -e PROJECT_NAME=${project_name} simonjan2/employee_management_flask_test:${app_version}

# Print Docker logs for debugging
CONTAINER_ID=$(sudo docker ps -q)
sudo docker logs $CONTAINER_ID