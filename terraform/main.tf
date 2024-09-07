resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask from anywhere"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_ebs_volume" "mysql_data" {
  availability_zone = var.availability_zone
  size              = 20  # Size in GiB

  tags = {
    Name = "mysql-data"
  }
}

resource "aws_volume_attachment" "mysql_data_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.mysql_data.id
  instance_id = aws_instance.main.id
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_name}-uploads"
}

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = aws_subnet.main.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_profile.name

  user_data = templatefile("userdata.sh", {
  app_version = var.app_version,
  project_name = var.project_name
  })

  tags = {
    Name = "${var.project_name}-instance"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "EC2S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "EC2S3Profile"
  role = aws_iam_role.ec2_s3_access_role.name
}