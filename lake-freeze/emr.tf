
resource "aws_emr_studio" "default_studio" {
  name                        = "default-studio"
  auth_mode                   = "IAM"
  default_s3_location         = "s3://${aws_s3_bucket.emr_zone.bucket}/studios/default-studio/"

  workspace_security_group_id = aws_security_group.allow_all.id
  engine_security_group_id    = aws_security_group.allow_all.id

  service_role                = aws_iam_role.backend_role.arn  
  vpc_id                      = var.vpc_id
  subnet_ids                  = [var.subnet_ids[0]]
}