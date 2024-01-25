terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0.0"
        }
        databricks = {
            source  = "databricks/databricks"
            version = ">= 1.33.0"
        }
        databricks_ws = {
            source  = "databricks/databricks"
            version = ">= 1.33.0"
        }
    }
}
