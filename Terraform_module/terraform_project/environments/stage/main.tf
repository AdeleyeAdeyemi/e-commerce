# Stage environment root configuration
# Usage: terraform -chdir=environments/stage init
#        terraform -chdir=environments/stage plan
#        terraform -chdir=environments/stage apply

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}

module "subnet" {
  source = "../../modules/subnet"

  vpc_id                         = module.vpc.vpc_id
  public_subnet_az1_cidr         = var.public_subnet_az1_cidr
  public_subnet_az2_cidr         = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr    = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr    = var.private_app_subnet_az2_cidr
  private_db_subnet_az1_cidr     = var.private_db_subnet_az1_cidr
  private_db_subnet_az2_cidr     = var.private_db_subnet_az2_cidr
  az1          = data.aws_availability_zones.available.names[0]
  az2          = data.aws_availability_zones.available.names[1]
  project_name = var.project_name
}

module "security_group" {
  source = "../../modules/security_group"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}

module "ec2" {
  source = "../../modules/ec2"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_pair_name      = var.key_pair_name
  subnet_id          = module.subnet.public_subnet_az1_id
  security_group_id  = module.security_group.security_group_id
  project_name       = var.project_name
  environment        = var.environment
  owner              = var.owner
}

module "security_group_alb" {
  source = "../../modules/security_group"

  vpc_id       = module.vpc.vpc_id
  project_name = "${var.project_name}-alb"
}

module "alb" {
  source = "../../modules/alb"

  project_name        = var.project_name
  security_group_id   = module.security_group_alb.security_group_id
  subnet_ids          = [module.subnet.public_subnet_az1_id, module.subnet.public_subnet_az2_id]
  vpc_id              = module.vpc.vpc_id
  listener_port       = 80
  target_group_port   = 80
}

module "route_table" {
  source = "../../modules/route_table"

  vpc_id                        = module.vpc.vpc_id
  internet_gateway_id           = module.subnet.internet_gateway_id
  public_subnet_az1_id          = module.subnet.public_subnet_az1_id
  public_subnet_az2_id          = module.subnet.public_subnet_az2_id
  private_app_subnet_az1_id     = module.subnet.private_app_subnet_az1_id
  private_app_subnet_az2_id     = module.subnet.private_app_subnet_az2_id
  private_db_subnet_az1_id      = module.subnet.private_db_subnet_az1_id
  private_db_subnet_az2_id      = module.subnet.private_db_subnet_az2_id
  project_name                  = var.project_name
}

module "rds" {
  source = "../../modules/rds"

  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
  multi_az           = var.multi_az
  db_subnet_ids      = [module.subnet.private_db_subnet_az1_id, module.subnet.private_db_subnet_az2_id]
  security_group_id  = module.security_group.security_group_id
  project_name       = var.project_name
  environment        = var.environment
  owner              = var.owner
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = var.bucket_name
  environment = var.environment
  owner       = var.owner
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name       = var.project_name
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  key_pair_name      = var.key_pair_name
  security_group_id  = module.security_group.security_group_id
  subnet_ids         = [module.subnet.private_app_subnet_az1_id, module.subnet.private_app_subnet_az2_id]
  target_group_arns  = [module.alb.target_group_arn]
  min_size           = 1
  max_size           = 5
  desired_capacity   = 2
  environment        = var.environment
  owner              = var.owner
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}
