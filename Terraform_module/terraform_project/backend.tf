terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-kadel"
    key            = "terraform_project/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = "true"
    
  }
}
