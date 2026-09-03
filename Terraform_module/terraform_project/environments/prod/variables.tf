variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_az1_cidr" {
  type = string
}

variable "public_subnet_az2_cidr" {
  type = string
}

variable "private_app_subnet_az1_cidr" {
  type = string
}

variable "private_app_subnet_az2_cidr" {
  type = string
}

variable "private_db_subnet_az1_cidr" {
  type = string
}

variable "private_db_subnet_az2_cidr" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "multi_az" {
  type = bool
}

variable "bucket_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "application" {
  type = string
}
