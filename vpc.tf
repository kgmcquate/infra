data "aws_caller_identity" "current" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true

  # enable_nat_gateway = true
  # single_nat_gateway = true

  map_public_ip_on_launch = true # assign IPS to public instances
}

resource "aws_security_group_rule" "default_vpc_ingress" {
  security_group_id = module.vpc.default_security_group_id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = -1
}


resource "aws_security_group_rule" "default_vpc_egress" {
  security_group_id = module.vpc.default_security_group_id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = -1
}
