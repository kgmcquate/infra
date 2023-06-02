
resource "aws_iam_user" "github_actions_cicd_user" {
  name = "github-actions-cicd-user"

  assume_role_policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudformation.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
  )
}


resource "aws_iam_user_policy" "github_actions_cicd_user_policy" {
  name   = "github_actions_cicd_user"
  user   = aws_iam_user.github-actions-cicd-user.name
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowS3BucketActions",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.public_zone}",
                "arn:aws:s3:::${aws_s3_bucket.deployment_zone}"
                ]
            },
        {
            "Sid": "AllowS3ObjectActions",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.public_zone}/*",
                "arn:aws:s3:::${aws_s3_bucket.deployment_zone}/*"
            ]
        },
        {
            "Sid": "AllowSCloudFrontActions",
            "Effect": "Allow",
            "Action": [
                "cloudfront:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "apigateway:*"
            ],
            "Resource": "*"
        }
    ]
    }
  )
}

resource "aws_iam_access_key" "github_actions_cicd_user_access_key" {
  user = aws_iam_user.my_user.name
}
  