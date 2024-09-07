project_name      = "employee-management"
aws_region        = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
subnet_cidr       = "10.0.1.0/24"
availability_zone = "us-east-1a"
ami_id            = "ami-066784287e358dad1"  # Amazon Linux 2 AMI (HVM), SSD Volume Type
instance_type     = "t2.micro"
app_version       = "v1.0.7" # 
#key_name          = "your-key-pair-name"  # Replace with your actual key pair name

# whenever you want to deploy a new version of your application:
#   1. Build and push your Docker image with a new tag (e.g., v1.0.1, v1.0.2, etc.) to Docker Hub.
#   2. Update the app_version in your terraform.tfvars file with the new tag.
#   3. Run terraform apply.