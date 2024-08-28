


resource "aws_iam_role" "service_role" {

  name = "service-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEc2AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEventsAssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowEMRServerlessAssumeRole"
        Principal = {
          Service = "ops.emr-serverless.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowLambdaAssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowStepFunctionsAssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "service_role_policy" {
  name = "general-access-policy"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
          "secretsmanager:*",
          "s3:*",
          "cloudtrail:*",
          "emr-serverless:*",
          "lambda:*",
          "rds:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["iam:PassRole"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}



