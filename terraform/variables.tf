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
  description = "CIDR block for the main subnet"
  type        = string
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the main subnet"
  type        = string
}

variable "secondary_availability_zone" {
  description = "Availability Zone for the secondary subnet"
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

variable "terraform_workspace" {
  description = "Terraform workspace name"
  type        = string
  default     = "default"
}