terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "= 2.23.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.17.0"
    }
  }
}