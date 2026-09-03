variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}

variable "public_subnet_az1_id" {
  description = "Public subnet AZ1 ID"
  type        = string
}

variable "public_subnet_az2_id" {
  description = "Public subnet AZ2 ID"
  type        = string
}

variable "private_app_subnet_az1_id" {
  description = "Private app subnet AZ1 ID"
  type        = string
}

variable "private_app_subnet_az2_id" {
  description = "Private app subnet AZ2 ID"
  type        = string
}

variable "private_db_subnet_az1_id" {
  description = "Private DB subnet AZ1 ID"
  type        = string
}

variable "private_db_subnet_az2_id" {
  description = "Private DB subnet AZ2 ID"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}
