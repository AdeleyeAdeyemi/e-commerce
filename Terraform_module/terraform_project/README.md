# Terraform Project

This repository contains a modular Terraform setup for provisioning AWS infrastructure across multiple environments (dev, stage, and prod).

## Project Structure
- Environments - Environment-specific deployment layers (dev, stage and prod).
  
- Global_variables - Global variable definitions used across all modules

- Modules - Reusable Terraform modules:
  * vpc
  * subnet
  * route_table
  * security_group
  * Ec2
  * Alb
  * Autoscaling
  * Rds
  * S3

- Shared
* Shared configuration files like provider and local
 
- Backend.tf - Root backend configuration (local state in the current setup)
- Main.tf - Root module orchestration for the environment-level deployment
- Variables.tf - Root input variables for the project


## What this Project Deploys

The Terraform configuration is designed to create a typical AWS application stack including:

* VPC with public and private subnets
* Internet Gateway and route tables
* Security groups for SSH, HTTP, and HTTPS
* EC2 instances
* Application Load Balancer
* Auto Scaling Group
* RDS database instance
* S3 bucket

## Environment Setup

Each environment has its own directory and configuration files:

- Environments/dev
- Environments/stage
- Environments/prod

Each environment directory contains:

- Main.tf - Environment module wiring
- variables.tf - Declared environment inputs
- Terraform.tfvars - Actual environment-specific values
- Backend.tf - Backend configuration (local state)
- Versions.tf - Provider and Terraform version constraints

## Local Execution

This repo is currently configured to use a local state backend, so AWS credentials are not required for initialization.

To initialize and apply an environment:

```bash
cd terraform_project/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Replace "dev" with "stage" or "prod" to target the other environments.





