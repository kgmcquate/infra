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
#   region = "us-east-1"
#   access_key = var.AWS_ACCESS_KEY_ID  #Creds provided in environment variables
#   secret_key = var.AWS_SECRET_ACCESS_KEY
}