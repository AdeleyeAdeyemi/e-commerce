##############################
# OUTPUTS
##############################
output "public_ip" {
  description = "Public IP of the Flask app"
  value       = aws_instance.flask_app.public_ip
}

output "private_key_pem" {
  description = "Private key for SSH access"
  value       = tls_private_key.terraform_key.private_key_pem
  sensitive   = true
}

output "security_group_id" {
  description = "ID of the Flask app security group"
  value       = aws_security_group.flask_sg.id
}

