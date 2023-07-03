module "nat" {
  source = "int128/nat-instance/aws"

  name                        = "nat"
  key_name                    = aws_key_pair.ssh.key_name
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids
}

resource "aws_eip" "nat" {
  network_interface = module.nat.eni_id
  tags = {
    "Name" = "nat-instance-main"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_ingress" {
  security_group_id = module.nat.sg_id

  cidr_ipv4       = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol          = -1
}

resource "aws_vpc_security_group_egress_rule" "nat_egress" {
  security_group_id = module.nat.sg_id

  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 80
  to_port           = 65535
  ip_protocol          = -1
}