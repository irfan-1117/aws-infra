data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefix}/base/vpc_id"
}
data "aws_ssm_parameter" "subnet" {
  name = "/${var.prefix}/base/subnet/a/id"
}

locals {
  vpc_id    = data.aws_ssm_parameter.vpc_id.value
  subnet_id = data.aws_ssm_parameter.subnet.value
}

module "ansible" {
  source = "./ansible-host"
  region = var.region
}

module "application" {
  source = "./application-host"
  region = var.region
}

module "kubernetes" {
  source = "./K8s-host"
  region = var.region
}