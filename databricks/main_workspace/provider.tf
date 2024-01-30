terraform {
    required_providers {
        databricks = {
            source  = "databricks/databricks"
            version = ">= 1.33.0"
        }
    }
}

provider "databricks" {
  alias ="main-ws"
}
provider databricks {}