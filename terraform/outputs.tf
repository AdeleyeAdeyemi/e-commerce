# Output public IP of the Flask app
output "public_ip" {
  description = "Public IP of the Flask app"
  value       = aws_instance.flask_app.public_ip
}

# Output private key for Jenkins/Ansible (do NOT store locally)
output "private_key_pem" {
  description = "Private key for SSH access"
  value       = tls_private_key.terraform_key.private_key_pem
  sensitive   = true
}
