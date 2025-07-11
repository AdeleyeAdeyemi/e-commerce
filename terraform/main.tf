provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "flask_app" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (London Region)
  instance_type          = "t2.micro"
  key_name               = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "flask-e-commerce-app"
  }

  provisioner "local-exec" {
    command = "echo '[web]\n${self.public_ip}' > ../ansible/inventory.ini"
  }
}
