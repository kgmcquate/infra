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
        pulsar = {
        source = "streamnative/pulsar"
        version = ">= 0.2.3"
        }
    }
}


