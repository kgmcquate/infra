terraform {
    # backend "remote" {
    #     # The name of your Terraform Cloud organization.
    #     organization = "kgmcquate"

    #     # The name of the Terraform Cloud workspace to store Terraform state files in.
    #     workspaces {
    #         name = "infra"
    #     }
    # }

    backend "s3" {}

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0.0"
        }
    }
}


variable "AWS_REGION" {
    type    = string
}

variable "AWS_ACCESS_KEY_ID" {
    type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
    type    = string
}


provider "aws" {
  region = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID 
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# resource "aws_s3_bucket" "deployment_bucket" {
  
# }