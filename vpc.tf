# Reference: https://medium.com/appgambit/terraform-aws-vpc-with-private-public-subnets-with-nat-4094ad2ab331

# resource "aws_vpc" "vpc" {
#   cidr_block           = "${var.vpc_cidr}"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   tags = {
#     Name        = "${var.environment}-vpc"
#     Environment = "${var.environment}"
#   }
# }

data "aws_caller_identity" "current" {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_security_group" "default" {
  id = "sg-e0fa90d6"
}
  
resource "aws_default_subnet" "a" {
  availability_zone = "${data.aws_region.current.name}a"
}
  
resource "aws_default_subnet" "b" {
  availability_zone = "${data.aws_region.current.name}b"
}

resource "aws_default_subnet" "c" {
  availability_zone = "${data.aws_region.current.name}c"
}


locals {
  environment = "prod"
  private_subnets_cidr = ["10.0.10.0/24"]
  availability_zones = ["${data.aws_region.current}a"]
}

/*==== Subnets ======*/
# /* Internet gateway for the public subnet */
# resource "aws_internet_gateway" "ig" {
#   vpc_id = "${aws_default_vpc.default.id}"
#   tags = {
#     Name        = "${var.environment}-igw"
#     Environment = "${var.environment}"
#   }
# }

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}
/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  # depends_on = [aws_internet_gateway.ig]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  # depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
    Environment = "${var.environment}"
  }
}

# /* Public subnet */
# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = "${aws_default_vpc.default.id}"
#   count                   = "${length(var.public_subnets_cidr)}"
#   cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
#   availability_zone       = "${element(var.availability_zones,   count.index)}"
#   map_public_ip_on_launch = true
#   tags = {
#     Name        = "${var.environment}-${element(var.availability_zones, count.index)}-      public-subnet"
#     Environment = "${var.environment}"
#   }
# }


/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_default_vpc.default.id}"
  count                   = "${length(local.private_subnets_cidr)}"
  cidr_block              = "${element(local.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(local.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${local.environment}-${element(local.availability_zones, count.index)}-private-subnet"
    Environment = "${local.environment}"
  }
}
/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_default_vpc.default.id}"
  tags = {
    Name        = "${local.environment}-private-route-table"
    Environment = "${local.environment}"
  }
}

/* Routing table for public subnet */
# resource "aws_route_table" "public" {
#   vpc_id = "${aws_default_vpc.default.id}"
#   tags = {
#     Name        = "${local.environment}-public-route-table"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_route" "public_internet_gateway" {
#   route_table_id         = "${aws_route_table.public.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = "${aws_internet_gateway.ig.id}"
# }

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
# resource "aws_route_table_association" "public" {
#   count          = "${length(local.public_subnets_cidr)}"
#   subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
#   route_table_id = "${aws_route_table.public.id}"
# }

resource "aws_route_table_association" "private" {
  count          = "${length(local.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*==== VPC's Default Security Group ======*/
# resource "aws_security_group" "default" {
#   name        = "${local.environment}-default-sg"
#   description = "Default security group to allow inbound/outbound from the VPC"
#   vpc_id      = "${aws_default_vpc.default.id}"
#   depends_on  = [aws_default_vpc.default]
#   ingress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = true
#   }
  
#   egress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = "true"
#   }
#   tags = {
#     Environment = "${local.environment}"
#   }
# }