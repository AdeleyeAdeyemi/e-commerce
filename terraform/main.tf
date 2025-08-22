# Variables
variable "sg_name" {
  description = "Name of the security group for Flask + ELK"
  type        = string
  default     = "flask-app-sg"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Provider
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group for Flask + ELK
resource "aws_security_group" "flask_sg" {
  name        = var.sg_name
  description = "Allow SSH, Flask app, and ELK ports"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 8777
    to_port     = 8777
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask app port"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Elasticsearch"
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash"
  }

  ingress {
    from_port   = 9600
    to_port     = 9600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Logstash monitoring"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

# Get Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Generate SSH keypair inside Terraform
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh
}

# EC2 Instance
resource "aws_instance" "flask_app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "flask-e-commerce-app"
    App  = "Flask"
  }

  # Write public IP into Ansible inventory
  provisioner "local-exec" {
    command = "echo '[web]\n${self.public_ip}' > ../ansible/inventory.ini"
  }
}

# Outputs
output "flask_app_public_ip" {
  description = "Public IP of the Flask EC2 instance"
  value       = aws_instance.flask_app.public_ip
}

output "private_key_pem" {
  description = "Private key (PEM) generated for SSH"
  value       = tls_private_key.my_key.private_key_pem
  sensitive   = true
}



