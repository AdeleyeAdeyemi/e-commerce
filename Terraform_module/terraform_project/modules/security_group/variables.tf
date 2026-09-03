variable "vpc_id" {
  description = "VPC ID to create security group in"
  type        = string
}

variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
