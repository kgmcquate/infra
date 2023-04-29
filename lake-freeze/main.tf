

variable POSTGRES_PWD {
  type = string
}


resource "aws_kms_key" "db_key" {
  description = "KMS key for encrypting database"
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ]

  inline_policy {
    name = "SMReadAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["secretsmanager:GetSecretValue"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

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

data "aws_iam_policy_document" "cloud9policy" {
  statement {
    sid    = "AllowReadSMforCloud9"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::117819748843:role/service-role/AWSCloud9SSMAccessRole"]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "policy" {
  secret_arn = aws_secretsmanager_secret.db_creds.arn
  policy     = data.aws_iam_policy_document.cloud9policy.json
}


data "aws_security_group" "default" {
  id = "sg-e0fa90d6"
}


resource "aws_db_instance" "default" {
  identifier = "lake-freeze-db"

  allocated_storage    = 10
  max_allocated_storage = 100
  db_name              = "lake_freeze"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = "db.t4g.micro"
  username             = local.db_username
  password             = local.db_password
  skip_final_snapshot  = true

  iam_database_authentication_enabled = true
  vpc_security_group_ids = [data.aws_security_group.default.id]
  multi_az = false
  publicly_accessible = true
  port = 5432

  
}


# resource "aws_rds_cluster" "db" {
#     cluster_identifier      = "lake-freeze-backend-db"
#     apply_immediately = true
#     engine                  = "postgres"
#     engine_version = "15.2"
#     engine_mode = "provisioned"

#     allocated_storage = 10


#     port = 5432
#     availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"] 
#     database_name           = "lake_freeze"
#     master_username         = local.db_username
#     # manage_master_user_password = true
#     master_password         = local.db_password
#     storage_encrypted = false
#     # kms_key_id = aws_kms_key.db_key.arn
#     iam_database_authentication_enabled = true
#     # iam_roles = ["arn:aws:iam::117819748843:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]

#     deletion_protection = false
#     skip_final_snapshot = true
#     final_snapshot_identifier = "lake-freeze-backend-db-final-snapshot"
#     backup_retention_period = 7
#     preferred_backup_window = "07:00-09:00"

#     enable_http_endpoint  = false
  
#     vpc_security_group_ids = [data.aws_security_group.default.id]
# }



# resource "aws_rds_cluster_instance" "instance-1" {
#   count              = 1
#   cluster_identifier = aws_rds_cluster.db.id
#   instance_class     = "db.t4g.micro"
#   engine             = aws_rds_cluster.db.engine
#   engine_version     = aws_rds_cluster.db.engine_version
  
#   publicly_accessible = true
# }


# Networking for rds/lambda

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# resource "aws_security_group" "lambda_sg" {
#   name        = "lambda_to_rds"
#   description = "Security Group for Lambda Egress"
#   vpc_id      = aws_default_vpc.default.id

#   egress {
#     description      = "inbound rules"
#     from_port        = 5432
#     to_port          = 5432
#     protocol         = "tcp"
#     cidr_blocks      = [aws_default_vpc.default.cidr_block]
# #     ipv6_cidr_blocks = [aws_default_vpc.default.ipv6_cidr_block]
#   }
# }


# resource "aws_security_group" "rds_sg" {
#   name        = "rds_to_lambda"
#   description = "Security Group for RDS"
#   vpc_id      = aws_default_vpc.default.id

#   ingress {
#     from_port        = 5432
#     to_port          = 5432
#     protocol         = "tcp"
#     cidr_blocks      = [aws_default_vpc.default.cidr_block]
#     security_groups = [aws_security_group.lambda_sg.id]
    
#   }

#   tags = {
#     Name = "allow_tls"
#   }
# }
