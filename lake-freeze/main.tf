





# resource "aws_cloudwatch_log_group" "log_group" {
#   name = "lake-freeze"
# }

resource "aws_ecs_cluster" "backend" {
  name = "lake-freeze-backend"

#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
}

resource aws_ecs_cluster_capacity_providers capacity_provider {
    cluster_name = aws_ecs_cluster.backend.name

    capacity_providers = ["FARGATE"]
}

variable POSTGRES_PWD {
  type = string
}


resource "aws_kms_key" "db_key" {
  description = "KMS key for encrypting database"
}

# data "aws_secretsmanager_secret" "db_pwd" {
#   arn = "arn:aws:secretsmanager:us-east-1:117819748843:secret:lake_freeze/db_pwd-qipFQc"
# }

resource "aws_iam_role" "db_role" {
  name = "lake-freeze-lambda-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "rds.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })



  managed_policy_arns = ["arn:aws:iam::aws:policy/aws-service-role/AmazonRDSServiceRolePolicy"]

  # inline_policy {
  #   name = "my_inline_policy"

  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Action   = ["ec2:Describe*"]
  #         Effect   = "Allow"
  #         Resource = "*"
  #       },
  #     ]
  #   })
  # }

}


resource "aws_iam_role" "backend_role" {
  name = "lake-freeze-lambda-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  # managed_policy_arns = []

  # inline_policy {
  #   name = "my_inline_policy"

  #   policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Action   = ["ec2:Describe*"]
  #         Effect   = "Allow"
  #         Resource = "*"
  #       },
  #     ]
  #   })
  # }

}

resource "random_password" "db_password" {
  length           = 8
  special          = true
  override_special = "_%@"
}
 
locals {
  db_username = "postgres"
  db_password = random_password.db_password.result
}


 # Creating a AWS secret for database master account (Masteraccoundb)
 
resource "aws_secretsmanager_secret" "db_creds" {
   name = "rds-lake-freeze-credentials"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = <<EOF
   {
    "username": "${local.db_username}",
    "password": "${local.db_password}"
   }
EOF
}


# Importing the AWS secrets created previously using arn.
 
# data "aws_secretsmanager_secret" "db_creds" {
#   arn = aws_secretsmanager_secret.db_creds.arn
# }
 
# Importing the AWS secret version created previously using arn.
 
# data "aws_secretsmanager_secret_version" "creds" {
#   secret_id = aws_secretsmanager_secret.db_creds.arn
# }

# locals {
#   db_password = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
# }




resource "aws_rds_cluster" "db" {
    cluster_identifier      = "lake-freeze-db"
    apply_immediately = true
    engine                  = "aurora-postgresql"
    engine_version = "14.6"
    engine_mode = "provisioned"
    port = 5432
    availability_zones      = ["us-east-1d", "us-east-1f"]
    database_name           = "lake_freeze"
    master_username         = local.db_username
    # manage_master_user_password = true
    master_password         = local.db_password
    storage_encrypted = true
    kms_key_id = aws_kms_key.db_key.arn
    iam_database_authentication_enabled = true
    iam_roles = [aws_iam_role.db_role.arn]

    deletion_protection = false
    skip_final_snapshot = true
    backup_retention_period = 7
    preferred_backup_window = "07:00-09:00"

    enable_http_endpoint  = false

    serverlessv2_scaling_configuration {
      min_capacity = 0.5
      max_capacity = 2.0
    }
}


resource "aws_rds_cluster_instance" "instance-1" {
  cluster_identifier = aws_rds_cluster.db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.db.engine
  engine_version     = aws_rds_cluster.db.engine_version
}

# Repo for storing docker images for Lambda
resource "aws_ecr_repository" "docker_repo" {
  name = "lake-freeze"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository_policy" "docker_repo_policy" {
  repository = aws_ecr_repository.docker_repo.name
  policy     = data.aws_iam_policy_document.docker_repo_policy.json
}

data "aws_iam_policy_document" "docker_repo_policy" {
  statement {
    sid    = "ECRReadImage"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      # "ecr:PutImage",
      # "ecr:InitiateLayerUpload",
      # "ecr:UploadLayerPart",
      # "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      # "ecr:DeleteRepository",
      # "ecr:BatchDeleteImage",
      # "ecr:SetRepositoryPolicy",
      # "ecr:DeleteRepositoryPolicy",
    ]
  }
}