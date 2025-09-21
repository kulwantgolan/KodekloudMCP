# Vulnerable Terraform Project - Security Analysis Lab

## Purpose
This Terraform configuration is **intentionally vulnerable** and designed for educational purposes to demonstrate security scanning with Terraform MCP Server and Checkov.

## ⚠️ WARNING
**DO NOT USE THIS CODE IN PRODUCTION!** This configuration contains multiple security vulnerabilities that are intentionally included for learning purposes.

## Intentional Security Issues

This project contains the following security vulnerabilities for analysis:

### S3 Bucket Issues
- No encryption at rest configured
- Public read ACL enabled
- No versioning enabled
- No logging configured

### Security Group Issues
- Allows all inbound traffic (0.0.0.0/0 on all ports)
- SSH (port 22) open to the world
- No egress restrictions

### EC2 Instance Issues
- Unencrypted root volume
- Public IP address assigned
- Sensitive data in user data script
- No IAM instance profile
- No monitoring enabled

### RDS Database Issues
- Unencrypted storage
- Weak password hardcoded in configuration
- No deletion protection
- Skip final snapshot enabled
- Using default security group with overly permissive rules

### Network Issues
- All resources in public subnets
- No private subnets configured
- No NAT gateway for private resources
- No network segmentation

### General Issues
- Sensitive values (passwords, API keys) hardcoded
- No tagging strategy for compliance
- No backup strategies configured
- No KMS keys for encryption

## Expected Checkov Findings

When running security analysis with Terraform MCP Server, you should see findings for:
- CKV_AWS_* checks for various AWS resource misconfigurations
- Password and secret detection
- Network exposure risks
- Encryption compliance issues
- Best practice violations

## Learning Objectives

1. Understand common infrastructure security misconfigurations
2. Learn how to use automated security scanning tools
3. Practice identifying and fixing security issues
4. Understand the importance of Infrastructure as Code security

## Files

- `main.tf` - Main Terraform configuration with resources
- `variables.tf` - Input variables (with insecure defaults)
- `outputs.tf` - Output values (some should be marked sensitive)
- `README.md` - This file

## Usage in the Lab

This project will be analyzed using:
1. Terraform MCP Server for natural language interaction
2. Checkov for automated security scanning
3. Claude Code for generating security reports

The goal is to identify all security issues and understand how to fix them.