variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"  # London
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}
