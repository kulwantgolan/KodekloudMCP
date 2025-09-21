# Main Terraform configuration with intentional security issues for analysis
# This is for educational purposes to demonstrate security scanning

provider "aws" {
  region = var.aws_region
}

# S3 Bucket with security issues
resource "aws_s3_bucket" "data_storage" {
  bucket = "${var.project_name}-data-storage-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Data Storage Bucket"
    Environment = var.environment
    # Missing encryption configuration - SECURITY ISSUE
  }
}

# Public bucket ACL - SECURITY ISSUE
resource "aws_s3_bucket_acl" "data_storage_acl" {
  bucket = aws_s3_bucket.data_storage.id
  acl    = "public-read" # SECURITY ISSUE: Public access
}

# Security Group with overly permissive rules
resource "aws_security_group" "web_server" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server"
  vpc_id      = aws_vpc.main.id

  # Ingress rule allowing all traffic - SECURITY ISSUE
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # SECURITY ISSUE: Open to the world
  }

  # SSH access from anywhere - SECURITY ISSUE
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SECURITY ISSUE: SSH open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # All instances get public IPs

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# EC2 Instance with security issues
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.web_server.id]

  # No encryption specified for root block device - SECURITY ISSUE
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    # encrypted = false # SECURITY ISSUE: Unencrypted root volume
  }

  # Instance has public IP and is in public subnet
  associate_public_ip_address = true # SECURITY ISSUE: Public IP exposure

  # No IAM instance profile attached
  # No monitoring enabled

  tags = {
    Name        = "${var.project_name}-web-server"
    Environment = var.environment
  }

  # User data with potential secrets - SECURITY ISSUE
  user_data = <<-EOF
    #!/bin/bash
    echo "export DB_PASSWORD=SuperSecret123!" >> /etc/environment
    echo "export API_KEY=sk-1234567890abcdef" >> /etc/environment
  EOF
}

# RDS Database with security issues
resource "aws_db_instance" "database" {
  identifier     = "${var.project_name}-database"
  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  # storage_encrypted = false # SECURITY ISSUE: Unencrypted database

  db_name  = "appdb"
  username = "admin"
  password = "SimplePassword123" # SECURITY ISSUE: Weak password in code

  vpc_security_group_ids = [aws_security_group.web_server.id]
  db_subnet_group_name   = aws_db_subnet_group.database.name

  skip_final_snapshot = true # SECURITY ISSUE: No final snapshot
  deletion_protection = false # SECURITY ISSUE: No deletion protection

  # publicly_accessible = true # SECURITY ISSUE: Database publicly accessible

  tags = {
    Name        = "${var.project_name}-database"
    Environment = var.environment
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.public.id, aws_subnet.public_2.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Second public subnet for RDS
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Random ID for bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}