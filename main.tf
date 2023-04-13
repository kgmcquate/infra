terraform {
    backend "remote" {
        # The name of your Terraform Cloud organization.
        organization = "kgmcquate"

        # The name of the Terraform Cloud workspace to store Terraform state files in.
        workspaces {
            name = "infra"
        }
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

provider "aws" {
  region = "us-east-1"
#   access_key = "my-access-key"  #Creds provided in environment variables
#   secret_key = "my-secret-key"
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
