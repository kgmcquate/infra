
variable POSTGRES_PWD {
  type = string
}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "deployment_zone" {
  bucket = "deployment-zone-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "deployment-zone-block-public" {
  bucket = aws_s3_bucket.deployment_zone.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
  
  
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id = aws_default_vp.default.id
  service_name = "com.amazonaws.us-east-1.secretsmanager"
  policy = "Interface"
  subnet_ids = [
    aws_default_subnet.a.id,
    aws_default_subnet.b.id,
    aws_default_subnet.c.id,
  ]
  
  security_group_ids = [aws_security_group.default.id]
  
  ip_address_type = "ipv4"
  
  private_dns_enabled = true
  
}

  
