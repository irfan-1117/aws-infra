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
  source = "./EC2/jenkins-ansible-host"
  region = var.region
}

module "application" {
  source = "./EC2/application-host"
  region = var.region
}

module "kubernetes" {
  source = "./EC2/K8s-host"
  region = var.region
}