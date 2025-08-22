 HEAD
#!/bin/bash
set -e

# -----------------------------
# Get public IP and strip whitespace/newlines
# -----------------------------
PUBLIC_IP=$(terraform -chdir=terraform output -raw public_ip | tr -d '[:space:]')

# -----------------------------
# Get private key from Terraform output
# -----------------------------
terraform -chdir=terraform output -raw com-new.pem > com-new.pem

# Ensure correct permissions
chmod 600 terraform-key.pem

# -----------------------------
# Move private key to WSL home for proper access
# -----------------------------
KEY_WSL_PATH="$HOME/com-new.pem"
cp com-new.pem "$KEY_WSL_PATH"
chmod 600 "$KEY_WSL_PATH"

# -----------------------------
# Generate inventory file with proper YAML syntax
# -----------------------------
cat > inventory_generated.yml <<EOL
all:
  hosts:
    ${PUBLIC_IP}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${KEY_WSL_PATH}
      ansible_python_interpreter: /usr/bin/python3
EOL

# -----------------------------
# Ensure LF line endings (very important on Windows/WSL)
# -----------------------------
sed -i 's/\r$//' inventory_generated.yml

# -----------------------------
# Display result
# -----------------------------
echo "Inventory file generated:"
cat inventory_generated.yml

=======
#!/bin/bash
set -e

# -----------------------------
# Get public IP and strip whitespace/newlines
# -----------------------------
PUBLIC_IP=$(terraform -chdir=terraform output -raw public_ip | tr -d '[:space:]')

# -----------------------------
# Get private key from Terraform output
# -----------------------------
terraform -chdir=terraform output -raw terraform_key_pem > terraform-key.pem

# Ensure correct permissions
chmod 600 terraform-key.pem

# -----------------------------
# Move private key to WSL home for proper access
# -----------------------------
KEY_WSL_PATH="$HOME/terraform-key.pem"
cp terraform-key.pem "$KEY_WSL_PATH"
chmod 600 "$KEY_WSL_PATH"

# -----------------------------
# Generate inventory file with proper YAML syntax
# -----------------------------
cat > inventory_generated.yml <<EOL
all:
  hosts:
    ${PUBLIC_IP}:
      ansible_user: ec2-user
      ansible_ssh_private_key_file: ${KEY_WSL_PATH}
      ansible_python_interpreter: /usr/bin/python3
EOL

# -----------------------------
# Ensure LF line endings (very important on Windows/WSL)
# -----------------------------
sed -i 's/\r$//' inventory_generated.yml

# -----------------------------
# Display result
# -----------------------------
echo "Inventory file generated:"
cat inventory_generated.yml
>>>>>>> efdb569 (Save local changes to inventory)
