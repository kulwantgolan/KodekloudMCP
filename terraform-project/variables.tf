# Input variables for the Terraform configuration

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vulnerable-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false # Should be true for production
}

variable "enable_encryption" {
  description = "Enable encryption for storage"
  type        = bool
  default     = false # SECURITY ISSUE: Default is false
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # SECURITY ISSUE: Open to world by default
}