variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "listener_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}
