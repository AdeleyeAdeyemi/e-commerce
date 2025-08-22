# Get the public IP from Terraform
PUBLIC_IP=$(terraform -chdir=terraform output -raw public_ip)

# Get the private key from Terraform output
terraform -chdir=terraform output -raw terraform_key_pem > terraform-key.pem
chmod 600 terraform-key.pem

# Generate inventory file dynamically
cat > inventory_generated.yml <<EOL
all:
  hosts:
    ${PUBLIC_IP}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: $(pwd)/terraform-key.pem
      ansible_python_interpreter: /usr/bin/python3
EOL

