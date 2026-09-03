# Global variables for shared use across all environments and modules.
# Do not set provider configuration or sensitive defaults here.

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for compute resources"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "The EC2 instance type to use"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "CIDR block for public subnet AZ1"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "CIDR block for public subnet AZ2"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "CIDR block for private app subnet AZ1"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "CIDR block for private app subnet AZ2"
  type        = string
}

variable "private_db_subnet_az1_cidr" {
  description = "CIDR block for private DB subnet AZ1"
  type        = string
}

variable "private_db_subnet_az2_cidr" {
  description = "CIDR block for private DB subnet AZ2"
  type        = string
}

variable "aws_subnet1" {
  description = "Subnet ID for the first subnet"
  type        = string
}

variable "aws_subnet2" {
  description = "Subnet ID for the second subnet"
  type        = string
}

variable "aws_subnet3" {
  description = "Subnet ID for the third subnet"
  type        = string
}

variable "aws_security_group" {
  description = "Security group ID to attach to resources"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "key_pair_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "aws_alb" {
  description = "Application Load Balancer name or ARN"
  type        = string
}

variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "aws_target_group" {
  description = "Target group name or ARN"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "multi_az" {
  description = "Whether the RDS instance should be deployed across multiple AZs"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "owner" {
  description = "Resource owner or team name"
  type        = string
}

variable "application" {
  description = "Application name"
  type        = string
}

