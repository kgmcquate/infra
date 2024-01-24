module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = var.name
  cidr = var.cidr_block
  azs  = data.aws_availability_zones.available.names
  tags = var.tags

  enable_dns_hostnames = true
  enable_nat_gateway   = false # using EC2 for NAT gateway
  # single_nat_gateway   = true
  # create_igw           = true

  public_subnets = [cidrsubnet(var.cidr_block, 3, 0)]
  private_subnets = [
    cidrsubnet(var.cidr_block, 3, 1),
    cidrsubnet(var.cidr_block, 3, 2)
  ]

  manage_default_security_group = true
  default_security_group_name   = "${var.name}-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "Allow all internal TCP and UDP"
    self        = true
  }]
}



# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"

#   name                 = "main"
#   cidr                 = "10.0.0.0/16"
#   azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#   enable_dns_hostnames = true

#   enable_nat_gateway = false # 
#   # single_nat_gateway = true

#   map_public_ip_on_launch = true # assign IPs to public instances
# }
