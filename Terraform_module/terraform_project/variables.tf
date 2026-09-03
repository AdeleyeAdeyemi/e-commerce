# Root-level variables that reference global variables
# These are passed down to modules and environments

variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
}

variable "ami_id" {
  type        = string
  description = "The AMI ID to use for compute resources"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_az1_cidr" {
  type        = string
  description = "CIDR block for public subnet AZ1"
}

variable "public_subnet_az2_cidr" {
  type        = string
  description = "CIDR block for public subnet AZ2"
}

variable "private_app_subnet_az1_cidr" {
  type        = string
  description = "CIDR block for private app subnet AZ1"
}

variable "private_app_subnet_az2_cidr" {
  type        = string
  description = "CIDR block for private app subnet AZ2"
}

variable "private_db_subnet_az1_cidr" {
  type        = string
  description = "CIDR block for private DB subnet AZ1"
}

variable "private_db_subnet_az2_cidr" {
  type        = string
  description = "CIDR block for private DB subnet AZ2"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "key_pair_name" {
  type        = string
  description = "Key pair name for SSH access"
}

variable "listener_port" {
  type        = number
  description = "Port for the ALB listener"
  default     = 80
}

variable "target_group_port" {
  type        = number
  description = "Port for the target group"
  default     = 80
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database master username"
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "multi_az" {
  type        = bool
  description = "Multi-AZ deployment for RDS"
  default     = false
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "owner" {
  type        = string
  description = "Resource owner or team name"
}

variable "application" {
  type        = string
  description = "Application name"
}
