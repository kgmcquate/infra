
resource "aws_iam_user" "github_actions_cicd_user" {
  name = "github-actions-cicd-user"

#   assume_role_policy = jsonencode(
#     {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#         "Sid": "",
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "cloudformation.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#         }
#     ]
#     }
#   )
}

resource "aws_iam_user_policy" "github_actions_cicd_user_policy" {
  name   = "github_actions_cicd_user"
  user   = aws_iam_user.github_actions_cicd_user.name
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowIAMActions",
            "Effect": "Allow",
            "Action": [
                "iam:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowVPCActions",
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowSecretsManagerActions",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3BucketActions",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": [
                aws_s3_bucket.public_zone.arn,
                aws_s3_bucket.deployment_zone.arn,
                "arn:aws:s3:::terraform-state-117819748843-us-east-1"
            ]
        },
        {
            "Sid": "AllowS3ObjectActions",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.public_zone.arn}/*",
                "${aws_s3_bucket.deployment_zone.arn}/*",
                "arn:aws:s3:::terraform-state-117819748843-us-east-1/*"
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


