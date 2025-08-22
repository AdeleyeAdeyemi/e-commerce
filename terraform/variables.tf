##############################
# VARIABLES
##############################
variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

