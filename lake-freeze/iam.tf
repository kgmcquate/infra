
resource "aws_iam_role" "backend_role" {
  name = "lake-freeze-lambda-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "*.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        # {
        #     "Effect": "Allow",
        #     "Principal": {
        #         "Service": "elasticmapreduce.amazonaws.com"
        #     },
        #     "Action": "sts:AssumeRole"
        # },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "emr-serverless.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "scheduler.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

#   inline_policy {
#     name = "EMRServerlessPassRole"

#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#             {
#                 "Effect": "Allow",
#                 "Action": "iam:PassRole",
#                 "Resource": "arn:aws:iam::${}:role/JobRuntimeRoleForEMRServerless",
#                     "Condition": {
#                             "StringLike": {
#                                 "iam:PassedToService": "emr-serverless.amazonaws.com"
#                             }
#                         }
#             }
#       ]
#     })
#   }

    inline_policy {
        name = "PassRoleToSelf"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action   = ["iam:PassRole"]
            Effect   = "Allow"
            Resource = [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lake-freeze-lambda-role"
            ]
            }
        ]
        })
    }

    inline_policy {
        name = "StepFunctionsAccess"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action   = ["ecr:*"]
            Action   = ["states:*"]
            Effect   = "Allow"
            Resource = "*"
            }
        ]
        })
    }

    inline_policy {
        name = "ECRAccess"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action   = ["ecr:*"]
            Effect   = "Allow"
            Resource = "*"
            }
        ]
        })
    }

    inline_policy {
        name = "EMRServerlessAccess"

        policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
            Action   = ["emr-serverless:*"]
            Effect   = "Allow"
            Resource = "*"
            }
        ]
        })
    }

  inline_policy {
    name = "EventBridgeAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["scheduler:*", "events:*"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "SMReadAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["secretsmanager:GetSecretValue"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  inline_policy {
    name = "S3ReadAccess"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action   = [
                    # "s3:PutObject",
                    # "s3:GetObject",
                    # "s3:GetEncryptionConfiguration",
                    # "s3:ListBucket",
                    # "s3:DeleteObject",
                    "s3:*"
                ],
                Effect   = "Allow"
                Resource = "*" #["aws_s3_bucket.emr_zone.arn, "${aws_s3_bucket.emr_zone.arn}/*"]
            }
        ]
    })
  }


  inline_policy {
    name = "EMRStudio"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Sid": "AllowEMRReadOnlyActions",
                "Effect": "Allow",
                "Action": [
                    "elasticmapreduce:ListInstances",
                    "elasticmapreduce:DescribeCluster",
                    "elasticmapreduce:ListSteps"
                ],
                "Resource": "*"
            },
            {
                "Sid": "AllowEC2ENIActionsWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterfacePermission",
                    "ec2:DeleteNetworkInterface"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:network-interface/*"
                ],
                "Condition": {
                    "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowEC2ENIAttributeAction",
                "Effect": "Allow",
                "Action": [
                    "ec2:ModifyNetworkInterfaceAttribute"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:instance/*",
                    "arn:aws:ec2:*:*:network-interface/*",
                    "arn:aws:ec2:*:*:security-group/*"
                ]
            },
            {
                "Sid": "AllowEC2SecurityGroupActionsWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:AuthorizeSecurityGroupEgress",
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:RevokeSecurityGroupEgress",
                    "ec2:RevokeSecurityGroupIngress",
                    "ec2:DeleteNetworkInterfacePermission"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowDefaultEC2SecurityGroupsCreationWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateSecurityGroup"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:security-group/*"
                ],
                "Condition": {
                    "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowDefaultEC2SecurityGroupsCreationInVPCWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateSecurityGroup"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:vpc/*"
                ],
                "Condition": {
                    "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowAddingEMRTagsDuringDefaultSecurityGroupCreation",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags"
                ],
                "Resource": "arn:aws:ec2:*:*:security-group/*",
                "Condition": {
                    "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true",
                    "ec2:CreateAction": "CreateSecurityGroup"
                    }
                }
            },
            {
                "Sid": "AllowEC2ENICreationWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:network-interface/*"
                ],
                "Condition": {
                    "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowEC2ENICreationInSubnetAndSecurityGroupWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:subnet/*",
                    "arn:aws:ec2:*:*:security-group/*"
                ],
                "Condition": {
                    "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowAddingTagsDuringEC2ENICreation",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags"
                ],
                "Resource": "arn:aws:ec2:*:*:network-interface/*",
                "Condition": {
                    "StringEquals": {
                    "ec2:CreateAction": "CreateNetworkInterface"
                    }
                }
            },
            {
                "Sid": "AllowEC2ReadOnlyActions",
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DescribeTags",
                    "ec2:DescribeInstances",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeVpcs"
                ],
                "Resource": "*"
            },
            {
                "Sid": "AllowSecretsManagerReadOnlyActionsWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:GetSecretValue"
                ],
                "Resource": "arn:aws:secretsmanager:*:*:secret:*",
                "Condition": {
                    "StringEquals": {
                    "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "AllowWorkspaceCollaboration",
                "Effect": "Allow",
                "Action": [
                    "iam:GetUser",
                    "iam:GetRole",
                    "iam:ListUsers",
                    "iam:ListRoles",
                    "sso:GetManagedApplicationInstance",
                    "sso-directory:SearchUsers"
                ],
                "Resource": "*"
            }
        ]
    })
  }

}

