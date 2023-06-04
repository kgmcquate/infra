

 

resource "aws_emr_studio" "default_studio" {
      name                        = "default-studio"
  auth_mode                   = "IAM"
  default_s3_location         = "s3://${aws_s3_bucket.emr_zone.bucket}/studios/default-studio/"

  workspace_security_group_id = data.aws_security_group.default.id
  engine_security_group_id    = data.aws_security_group.default.id

  service_role                = aws_iam_role.backend_role.arn  
  vpc_id                      = aws_default_vpc.default.id
  subnet_ids                  = [aws_default_subnet.a.id]  
}