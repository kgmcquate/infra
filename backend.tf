terraform {
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
