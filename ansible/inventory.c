#!/bin/bash
set -e

# Get the public IP from Terraform and remove extra whitespace/newlines
PUBLIC_IP=$(terraform -chdir=terraform output -raw public_ip | tr -d '[:space:]')

# Get the private key from Terraform output
terraform -chdir=terraform output -raw terraform_key_pem > terraform-key.pem
chmod 600 terraform-key.pem

# Get absolute path to the private key
PRIVATE_KEY_PATH=$(realpath terraform-key.pem)

# Generate the Ansible inventory file
cat > inventory_generated.yml <<EOL
all:
  hosts:
    "${PUBLIC_IP}":
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${PRIVATE_KEY_PATH}
      ansible_python_interpreter: /usr/bin/python3
EOL

echo "Inventory generated successfully:"
cat inventory_generated.yml
