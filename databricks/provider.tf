terraform {
    required_providers {
        aws = {
            source  = "databricks/databricks"
            version = ">= 1.33.0"
        }
    }
}