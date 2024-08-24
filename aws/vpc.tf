
locals {
  az_postfixes = ["a", "b", "c"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"
  azs                  = [for p in local.az_postfixes : "${var.region}${p}"]
  private_subnets      = [for i, p in local.az_postfixes : "10.0.${i + 1}.0/24"]
  public_subnets       = [for i, p in local.az_postfixes : "10.0.10${i + 1}.0/24"]
  enable_dns_hostnames = true

  enable_nat_gateway = false #true
  # single_nat_gateway = true

  map_public_ip_on_launch = true # assign IPs to public instances
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}