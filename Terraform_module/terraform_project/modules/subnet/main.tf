resource "aws_subnet" "public_az1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-az1"
    Type = "Public"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-az2"
    Type = "Public"
  }
}

resource "aws_subnet" "private_app_az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_subnet_az1_cidr
  availability_zone = var.az1

  tags = {
    Name = "${var.project_name}-private-app-az1"
    Type = "Private-App"
  }
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_subnet_az2_cidr
  availability_zone = var.az2

  tags = {
    Name = "${var.project_name}-private-app-az2"
    Type = "Private-App"
  }
}

resource "aws_subnet" "private_db_az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_subnet_az1_cidr
  availability_zone = var.az1

  tags = {
    Name = "${var.project_name}-private-db-az1"
    Type = "Private-DB"
  }
}

resource "aws_subnet" "private_db_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_subnet_az2_cidr
  availability_zone = var.az2

  tags = {
    Name = "${var.project_name}-private-db-az2"
    Type = "Private-DB"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-igw"
  }
}