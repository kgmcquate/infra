data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {
  pass_roles = [aws_iam_role.instance_profile.arn]
}

resource "aws_iam_role" "cross_account_role" {
  name               = "${var.name}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags               = var.tags
  
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

## Adding 20 second timer to avoid Failed credential validation check
resource "time_sleep" "wait" {
  create_duration = "20s"
  depends_on = [
    aws_iam_role_policy.this
  ]
}


## Instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}_profile"
  role = aws_iam_role.instance_profile.name
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

resource "aws_iam_role" "instance_profile" {
  name               = "${var.name}_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "ReadSecretsManager"

    policy = jsonencode({
      Version = "2012-10-17"
      
    #   secretsmanager:Name
      Statement = [
        {
          Action   = [
                "secretsmanager:CreateSecret", 
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetSecretValue",
                "secretsmanager:PutSecretValue"
            ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
            "Sid" = "ListObjectsInBucket",
            "Effect" = "Allow",
            "Action" = ["s3:ListBucket"],
            "Resource" = ["arn:aws:s3:::data-zone-*"]
        },
        {
            "Sid" = "AllObjectActions",
            "Effect" = "Allow",
            "Action" = "s3:*Object",
            "Resource" = ["arn:aws:s3:::data-zone-*/*"]
        }
        
      ]
    })
  }
}