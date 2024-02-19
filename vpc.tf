
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name                 = "main"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true

  enable_nat_gateway = false #true
  # single_nat_gateway = true

  map_public_ip_on_launch = true # assign IPs to public instances
}

# resource "aws_vpc_security_group_ingress_rule" "default_vpc_ingress_ssh" {
#   security_group_id = module.vpc.default_security_group_id

#   cidr_ipv4       = "0.0.0.0/0"
#   from_port         = 22
#   to_port           = 22
#   ip_protocol          = "tcp"
# }

resource "aws_vpc_security_group_egress_rule" "default_vpc_egress" {
  security_group_id = module.vpc.default_security_group_id

  cidr_ipv4       = "0.0.0.0/0"
  # from_port         = 0
  # to_port           = 65535
  ip_protocol          = -1
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