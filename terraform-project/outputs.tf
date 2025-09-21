# Output values for the Terraform configuration

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web_server.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data_storage.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.data_storage.arn
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
  sensitive   = false # Should be true for production
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.database.endpoint
  sensitive   = false # Should be true for production
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.database.db_name
}