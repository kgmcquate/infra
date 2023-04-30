

variable POSTGRES_PWD {
  type = string
}

variable secrets_bucket {
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


locals {
  db_username = "postgres"
  db_password = var.POSTGRES_PWD
}
 
# resource "aws_secretsmanager_secret" "db_creds" {
#    name = "rds-lake-freeze-credentials"
# }

# resource "aws_secretsmanager_secret_version" "sversion" {
#   secret_id = aws_secretsmanager_secret.db_creds.id
#   secret_string = <<EOF
#    {
#     "username": "${local.db_username}",
#     "password": "${local.db_password}"
#    }
# EOF
# }

resource "aws_s3_object" "object" {
  bucket = var.secrets_bucket
  key    = "lake_freeze_credentials.json"
  content  = <<EOF
   {
    "username": "${local.db_username}",
    "password": "${local.db_password}"
   }
EOF
}



resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_security_group" "default" {
  id = "sg-e0fa90d6"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
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
  vpc_security_group_ids = [data.aws_security_group.default.id, aws_security_group.allow_all.id]
  multi_az = false
  publicly_accessible = true
  port = 5432

  
}



# Networking for rds/lambda




