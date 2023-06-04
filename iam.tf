
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


# Allow all policy
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "*"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#     ]
# }


resource "aws_iam_user_policy" "github_actions_cicd_user_policy" {
  depends_on = [module.lake-freeze]

  name   = "github_actions_cicd_user"
  user   = aws_iam_user.github_actions_cicd_user.name
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
           "Sid": "AllowEventBridgeActions",
          "Action"   = ["scheduler:*", "events:*"]
          "Effect"   = "Allow"
          "Resource" = "*"
        },
        {
            "Sid": "AllowIAMActions",
            "Effect": "Allow",
            "Action": [
                # "iam:Get*",
                # "iam:List*",
                # "iam:Describe*",
                "iam:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowVPCActions",
            "Effect": "Allow",
            "Action": [
                "ec2:Get*",
                "ec2:List*",
                "ec2:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowSecretsManagerActions",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:Create*",
                "secretsmanager:Get*",
                "secretsmanager:Delete*",
                "secretsmanager:Describe*",
                "secretsmanager:List*"

            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowEMRServerlessActions",
            "Effect": "Allow",
            "Action": [
                "emr-serverless:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3BucketActions",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*",
                "s3:Describe*",
                "s3:Create*"
            ],
            "Resource": [
                aws_s3_bucket.public_zone.arn,
                aws_s3_bucket.deployment_zone.arn,
                module.lake-freeze.aws_s3_bucket.emr_zone,
                # "emr-zone-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}",
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
            "Sid": "AllowSCloudFormationActions",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
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


