resource "aws_s3_bucket" "deployment_zone" {
  bucket = "deployment-zone-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "deployment-zone-block-public" {
  bucket = aws_s3_bucket.deployment_zone.id

  # block_public_acls       = true
  # block_public_policy     = true
  # ignore_public_acls      = true
  # restrict_public_buckets = true
}

resource "aws_s3_bucket" "public_zone" {
  bucket = "public-zone-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}
  
resource "aws_s3_bucket_public_access_block" "public-zone-public-access" {
  bucket = aws_s3_bucket.public_zone.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "allow_public_read_access" {
  bucket = aws_s3_bucket.public_zone.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.public_zone.arn}/*"
            ]
        }
    ]
  })
}


resource "aws_s3_bucket" "data_zone" {
  bucket = "data-zone-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}