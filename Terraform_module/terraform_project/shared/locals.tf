# Local values shared across all resources
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
    ManagedBy   = "Terraform"
  }
}
