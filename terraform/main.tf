provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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

resource "aws_instance" "flask_app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "flask-e-commerce-app"
  }

  provisioner "local-exec" {
    command = "echo '[web]\n${self.public_ip}' > ../ansible/inventory.ini"
  }
}
