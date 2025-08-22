##############################
# PROVIDER
##############################

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

##############################
# SSH KEY
##############################

resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_key" {
  key_name   = var.key_name
  public_key = tls_private_key.terraform_key.public_key_openssh

  lifecycle {
    prevent_destroy = true
  }
}

##############################
# SECURITY GROUP
##############################

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow SSH, Flask app, and ELK ports"
  vpc_id      = data.aws_vpc.default.id

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-app-sg"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "flask_app" {
  type              = "ingress"
  from_port         = 8777
  to_port           = 8777
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "elk_5044" {
  type              = "ingress"
  from_port         = 5044
  to_port           = 5044
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "elk_9200" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

resource "aws_security_group_rule" "elk_9600" {
  type              = "ingress"
  from_port         = 9600
  to_port           = 9600
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.flask_sg.id
}

##############################
# AMAZON LINUX AMI
##############################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

##############################
# EC2 INSTANCE
##############################

resource "aws_instance" "flask_app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "flask-app"
  }

  depends_on = [
    aws_security_group_rule.ssh,
    aws_security_group_rule.flask_app,
    aws_security_group_rule.elk_5044,
    aws_security_group_rule.elk_9200,
    aws_security_group_rule.elk_9600
  ]
}

