provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "eastus2"
}
