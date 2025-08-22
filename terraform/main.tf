provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create Security Group for Flask + ELK access
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH, Flask app, and ELK ports"
  vpc_id      = "vpc-0d1eaae379d646134" # make sure you have this variable

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
}

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
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "aws_instance" "flask_app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "flask-e-commerce-app"
  }

  provisioner "local-exec" {
    command = "echo '[web]\n${self.public_ip}' > ../ansible/inventory.ini"
  }
}

output "private_key_pem" {
  value     = tls_private_key.my_key.private_key_pem
  sensitive = true
}

output "flask_app_public_ip" {
  value = aws_instance.flask_app.public_ip
}

