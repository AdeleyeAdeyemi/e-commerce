terraform {
    backend "s3" {
        bucket         = var.s3_bucket
        key            = "terraform.tfstate"
        region         = var.region
        dynamodb_table = var.dynamodb_table_name
    }
}
