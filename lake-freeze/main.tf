





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

resource "aws_rds_cluster" "db" {
    cluster_identifier      = "lake-freeze"
    engine                  = "aurora-postgresql"
    engine_version = "14.6"
    engine_mode = "provisioned"
    port = 5432
    availability_zones      = ["us-east-1d", "us-east-1f"]
    database_name           = "lake_freeze"
    # master_username         = "postgres"
    manage_master_user_password = true
    # master_password         = data.aws_secretsmanager_secret.db_pwd.
    # kms_key_id = aws_kms_key.db_key.id
    iam_database_authentication_enabled = true
    iam_roles = []

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