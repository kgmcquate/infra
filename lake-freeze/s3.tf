
# data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "emr_zone" {
  bucket = "emr-zone-${data.aws_caller_identity.current.account_id}-us-east-1"
}