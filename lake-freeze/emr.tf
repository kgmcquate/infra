
resource "aws_default_subnet" "a" {
  availability_zone = "${data.aws_region.current.name}a"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_security_group" "default" {
  id = "sg-e0fa90d6"
}
  

resource "aws_emr_studio" "default_studio" {
  auth_mode                   = "IAM"
  default_s3_location         = "s3://${aws_s3_bucket.emr_zone.bucket}/studios/default-studio/"
  engine_security_group_id    = aws_security_group.test.id
  name                        = "default-studio"
  service_role                = aws_iam_role.backend_role.arn  
  vpc_id                      = aws_default_vpc.default.id
  subnet_ids                  = [aws_default_subnet.a.id]
  workspace_security_group_id = aws_security_group.default.id
}