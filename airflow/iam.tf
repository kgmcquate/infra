
resource "aws_iam_instance_profile" "airflow_profile" {
  name = "airflow_profile"
  role = aws_iam_role.airflow_profile.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "airflow_profile" {
  name               = "airflow_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  
  inline_policy {
    name = "ReadAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      
    #   secretsmanager:Name
      Statement = [
        {
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "redshift-data:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "*"
        },
        {
          
          Action   = [
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue"
            ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
            "Sid" = "ListObjectsInBucket",
            "Effect" = "Allow",
            "Action" = ["s3:ListBucket"],
            "Resource" = ["arn:aws:s3:::data-zone-*", "arn:aws:s3:::deployment-zone-*"]
        },
        {
            "Sid" = "AllObjectActions",
            "Effect" = "Allow",
            "Action" = "s3:*Object",
            "Resource" = ["arn:aws:s3:::data-zone-*/*", "arn:aws:s3:::deployment-zone-*/*"]
        },

        {
          Action   = ["ecr:*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["emr-serverless:*"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}