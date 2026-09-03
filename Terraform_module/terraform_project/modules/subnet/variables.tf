
variable "vpc_id" {
  description = "VPC ID to create subnets in"
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

variable "az1" {
  description = "First availability zone"
  type        = string
}

variable "az2" {
  description = "Second availability zone"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}
