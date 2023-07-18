# Setup our aws provider
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "techverito-terraform-infra-1117"
    region         = "us-east-1"
    dynamodb_table = "techverito-terraform-locks"
    key            = "base/terraform.tfstate"
  }
}

