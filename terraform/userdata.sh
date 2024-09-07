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
sudo mkdir /mnt/mysql-data
sudo mount /dev/xvdh /mnt/mysql-data

# Update MySQL data directory
sudo sed -i 's/datadir.*=.*/datadir = \/mnt\/mysql-data/' /etc/mysql/my.cnf

# Move existing MySQL data
sudo systemctl stop mysql
sudo mv /var/lib/mysql/* /mnt/mysql-data/
sudo chown -R mysql:mysql /mnt/mysql-data

# Start MySQL
sudo systemctl start mysql

# Pull and run the Docker image
sudo docker pull simonjan2/employee_management_flask_test:${app_version}
sudo docker run -d -p 80:5000 -v /mnt/mysql-data:/var/lib/mysql -e PROJECT_NAME=${project_name} simonjan2/employee_management_flask_test:${app_version}