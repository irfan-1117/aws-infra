# Setup our aws provider
variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.8.0"
    }
  }
}
