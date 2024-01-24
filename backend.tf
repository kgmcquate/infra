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
        databricks = {
            source  = "databricks/databricks"
            version = ">= 1.34.0"
        }
    }
}


