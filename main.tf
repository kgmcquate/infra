

provider "aws" {
  region = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID  #Creds provided in environment variables
  secret_key = var.AWS_SECRET_ACCESS_KEY
}



resource "aws_cloudwatch_log_group" "log_group" {
  name = "lake-freeze"
}

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
