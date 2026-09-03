output "public_subnet_az1_id" {
  description = "Public subnet AZ1 ID"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet AZ2 ID"
  value       = aws_subnet.public_az2.id
}

output "private_app_subnet_az1_id" {
  description = "Private app subnet AZ1 ID"
  value       = aws_subnet.private_app_az1.id
}

output "private_app_subnet_az2_id" {
  description = "Private app subnet AZ2 ID"
  value       = aws_subnet.private_app_az2.id
}

output "private_db_subnet_az1_id" {
  description = "Private DB subnet AZ1 ID"
  value       = aws_subnet.private_db_az1.id
}

output "private_db_subnet_az2_id" {
  description = "Private DB subnet AZ2 ID"
  value       = aws_subnet.private_db_az2.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}
