
resource "aws_iam_instance_profile" "pulsar_profile" {
  name = "pulsar_profile"
  role = aws_iam_role.pulsar_profile.name
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

resource "aws_iam_role" "pulsar_profile" {
  name               = "pulsar_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  
  inline_policy {
    name = "pulsar_superuser_token_access"

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
          Condition = {
            "StringEquals" = {
                "secretsmanager:Name" = local.pulsar_superuser_secret_name
            }
          }
        }
      ]
    })
  }
}