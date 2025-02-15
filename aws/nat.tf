module "nat" {
  source = "int128/nat-instance/aws"

  enabled = false

  name                        = "main-nat"
  key_name                    = aws_key_pair.ssh.key_name
  vpc_id                      = module.vpc.vpc_id
  public_subnet               = module.vpc.public_subnets[0]
  private_subnets_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  private_route_table_ids     = module.vpc.private_route_table_ids

  user_data_write_files = [
    {
      path : "/opt/nat/run_openvpn_client.sh",
      content : file("${path.module}/run_openvpn_client.sh"),
      permissions : "0755",
    },
  ]
#   user_data_runcmd = [
#     ["/opt/nat/run_openvpn_client.sh"],
#   ]

  # instance_types = ["t4g.nano"]
  # image_id = data.aws_ami.al2_arm64.id
}

data "aws_ami" "al2_arm64" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-arm64-gp2"]
  }
  owners = ["amazon"]
}

# resource "aws_eip" "nat" {
#   network_interface = module.nat.eni_id
#   tags = {
#     "Name" = "nat-instance-main"
#   }
# }

resource "aws_vpc_security_group_ingress_rule" "nat_ingress" {
  security_group_id = module.nat.sg_id

  cidr_ipv4       = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol          = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "nat_egress" {
  security_group_id = module.nat.sg_id

  cidr_ipv4 = "0.0.0.0/0"
#   from_port         = 80
#   to_port           = 65535
  ip_protocol          = -1
}

resource "aws_iam_policy" "nat_access_sm" {
    name = "nat_access_sm"
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
        {
            Effect = "Allow",
            Action = [
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            ],
            Resource = "*",
        },
        ],
    })
}

resource "aws_iam_policy_attachment" "nat_access_sm" {
    name = "nat_access_sm"
    roles = [module.nat.iam_role_name]
    policy_arn = aws_iam_policy.nat_access_sm.arn
}