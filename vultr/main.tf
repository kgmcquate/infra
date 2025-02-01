terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.23.1"
    }
  }
}

variable "api_key" {
  type = string
}

# Configure the Vultr Provider
provider "vultr" {
  api_key = var.api_key
  rate_limit = 100
  retry_limit = 3
}

resource "vultr_kubernetes" "main" {
  region  = "ewr"
  label   = "main"
  version = "v1.32.1+1"

  node_pools {
    node_quantity = 1
    plan          = "vc2-1c-2gb"
    label         = "main-nodepool"
    auto_scaler   = false
    min_nodes     = 1
    max_nodes     = 1
  }
}
