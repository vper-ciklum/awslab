
// TODO break public and private into separate AZs
data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "172.16.0.0/16"
  private_cidr = "172.16.2.0/24"
  public_cidr = "172.16.1.0/24"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = local.vpc_cidr
  azs                              = data.aws_availability_zones.available.names
  # private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets                  = [local.private_cidr]
  # public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24"]
  public_subnets                   = [local.public_cidr]
  #assign_generated_ipv6_cidr_block = true
  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = true

  private_subnet_tags = {
    Name = "${var.namespace}-subnet-private"
  }

  public_subnet_tags = {
    Name = "${var.namespace}-subnet-public"
  }
}

// SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.namespace}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_ssh_pub"
  }
}

// SG to onlly allow SSH connections from VPC public subnets
resource "aws_security_group" "allow_ssh_priv" {
  name        = "${var.namespace}-allow_ssh_priv"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH only from internal VPC clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_ssh_priv"
  }
}