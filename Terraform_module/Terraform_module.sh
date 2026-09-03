# i want to create terraform shell script for linux server that will create a structured modular file
# the script will craete a new directory, craeete a modules for vpc, ec2, s3, rds, security group, route table, associate route table with alb, autoscaling and outputs. It will also create a main.tf file that will call these modules.
# craete a variables.tf file for all the variables used in the modules and main.tf file and also output
# create a terrafoorm namespace for dev, stage, prod and create a backend.tf file for remote state management.
#  craete a global variable directory for storing global variables that can be used across all environments also provider, versions, backend and terraform.tfvars files for each environment.
# execute the script to create the directory structure and files.


# Here is a sample shell script that will create a structured modular file for Terraform on a Linux server. This script will create the necessary directories and files for VPC, EC2, S3, RDS, Security Group, Route Table, ALB, Auto Scaling, and outputs. It will also set up the main.tf, variables.tf, backend.tf, and environment-specific files.```bash
#!/bin/bash

# ============================================================================
# Terraform Enterprise Project Scaffold
# ============================================================================

BASE_DIR="terraform_project"

echo "Creating Terraform project structure..."

# Root
mkdir -p "$BASE_DIR"

# ============================================================================
# MODULES
# ============================================================================

MODULES=(
  vpc
  subnet
  route_table
  security_group
  ec2
  alb
  autoscaling
  rds
  s3
)

for module in "${MODULES[@]}"
do
    mkdir -p "$BASE_DIR/modules/$module"

    touch "$BASE_DIR/modules/$module/main.tf"
    touch "$BASE_DIR/modules/$module/variables.tf"
    touch "$BASE_DIR/modules/$module/outputs.tf"
done

# ============================================================================
# ENVIRONMENTS
# ============================================================================

for env in dev stage prod
do
    mkdir -p "$BASE_DIR/environments/$env"

    touch "$BASE_DIR/environments/$env/main.tf"
    touch "$BASE_DIR/environments/$env/variables.tf"
    touch "$BASE_DIR/environments/$env/provider.tf"
    touch "$BASE_DIR/environments/$env/versions.tf"
    touch "$BASE_DIR/environments/$env/backend.tf"
    touch "$BASE_DIR/environments/$env/terraform.tfvars"
done

# ============================================================================
# SHARED CONFIGURATION
# ============================================================================

mkdir -p "$BASE_DIR/shared"

touch "$BASE_DIR/shared/provider.tf"
touch "$BASE_DIR/shared/versions.tf"
touch "$BASE_DIR/shared/locals.tf"

# ============================================================================
# ROOT FILES
# ============================================================================

touch "$BASE_DIR/main.tf"
touch "$BASE_DIR/variables.tf"
touch "$BASE_DIR/backend.tf"
touch "$BASE_DIR/README.md"

# ============================================================================
# SAMPLE DEV VARIABLES
# ============================================================================

cat > "$BASE_DIR/environments/dev/terraform.tfvars" <<EOF

EOF

# ============================================================================
# SAMPLE STAGE VARIABLES
# ============================================================================

cat > "$BASE_DIR/environments/stage/terraform.tfvars" <<EOF

EOF

# ============================================================================
# SAMPLE PROD VARIABLES
# ============================================================================

cat > "$BASE_DIR/environments/prod/terraform.tfvars" <<EOF

echo ""
echo "Terraform project structure created successfully."
echo ""
EOF

# tree "$BASE_DIR"
