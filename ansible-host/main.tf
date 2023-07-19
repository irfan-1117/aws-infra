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

resource "aws_security_group" "ansible_sg" {
  name        = "${var.prefix}-ansible_sg"
  description = "Security group for Kubernetes cluster"

  vpc_id = local.vpc_id

  tags = {
    Name      = "SG for ansible"
    createdBy = "infra-${var.prefix}/base"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ansible-key"
  public_key = file("${path.module}/../id_rsa.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] #amazon
}

### creation of ansible-host

resource "aws_instance" "ansible-host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  availability_zone = "${var.region}a"

  subnet_id = local.subnet_id

  vpc_security_group_ids = [
    "${aws_security_group.ansible_sg.id}",
  ]

  user_data = <<-EOF
     #!/bin/bash

     # Update system packages
      sudo apt update -y

     # Install dependencies
      sudo apt-add-repository ppa:ansible/ansible -y
      sudo apt update -y
      sudo apt install ansible -y

     # Verify the installation
      ansible --version

     # Create a new user
      sudo useradd -m ansibleuser

     # Add the user to the sudoers file
      sudo bash -c 'echo "ansibleuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

     # Replace 'yes' with 'no' if you want to disable PasswordAuthentication
     
      sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

      sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

     # Restart the SSH service
      sudo systemctl restart sshd
  EOF

  tags = {
    Name      = "${var.prefix}-ansible-host"
    createdBy = "infra-${var.prefix}/base"
  }


}
### end of ansible-host
