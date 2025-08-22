##############################
# OUTPUTS
##############################
output "public_ip" {
  description = "Public IP of the Flask app"
  value       = aws_instance.flask_app.public_ip
}

output "security_group_id" {
  description = "ID of the Flask app security group"
  value       = aws_security_group.flask_sg.id
}


