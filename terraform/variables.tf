variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the subnet"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "app_version" {
  description = "Version of the application to deploy"
  type        = string
  default     = "latest"
}

# variable "key_name" {
#   description = "Name of the SSH key pair"
#   type        = string
# }



##### DB variables

variable "db_instance_type" {
  description = "Instance type for the MariaDB server"
  type        = string
  default     = "t2.micro"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "employee_management"
}

variable "db_username" {
  description = "username for the database user"
  type        = string
  default     = "user"
}

variable "db_password" {
  description = "Password for the database user"
  type        = string
  default     = "password"
}

variable "elastic_ip_id" {
  description = "The allocation ID of the Elastic IP to associate with the MariaDB instance"
  type        = string
}