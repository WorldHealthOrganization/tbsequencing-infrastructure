provider "aws" {
  region = local.aws_region
  default_tags {
    tags = local.tags
  }
}


terraform {
  backend "s3" {
    bucket         = "fdx-main-db-for-prod-tf-state"
    dynamodb_table = "fdx-main-db-for-prod-tf-state-lock"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
  }
}
