module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}


variable POSTGRES_PWD {
  type = string
}



  
data "aws_region" "current" {}
  


  
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

  
