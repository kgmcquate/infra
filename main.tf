
variable POSTGRES_PWD {
  type = string
}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}

data "aws_caller_identity" "current" {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

  
data "aws_region" "current" {}
  
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


  
# resource "aws_vpc_endpoint" "secretsmanager" {
#   vpc_id = aws_default_vpc.default.id
#   service_name = "com.amazonaws.us-east-1.secretsmanager"
#   vpc_endpoint_type = "Interface"
#   subnet_ids = [
#     aws_default_subnet.a.id,
#     aws_default_subnet.b.id,
#     aws_default_subnet.c.id,
#   ]
  
#   security_group_ids = [data.aws_security_group.default.id]
  
#   ip_address_type = "ipv4"
  
#   private_dns_enabled = true
  
# }

  
