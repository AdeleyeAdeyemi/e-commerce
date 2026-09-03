terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-kadel"
    key            = "terraform_project/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile = "true"
    
  }
}
