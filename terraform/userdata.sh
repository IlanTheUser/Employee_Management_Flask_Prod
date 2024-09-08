#!/bin/bash

# Update the system
sudo yum update -y

# Install and configure Docker
sudo amazon-linux-extras install docker -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on

# Pull and run the Docker image
# Replace 'your-image:tag' with the actual image name and tag from Docker Hub
sudo docker pull dckrilan/employee_management_flask_test:${app_version}
sudo docker run -d -p 80:5000 dckrilan/employee_management_flask_test:${app_version}


