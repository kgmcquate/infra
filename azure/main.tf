provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "main"
  location = "eastus2"
}

resource "azuread_group" "dagster" {
    display_name     = "dagster-users"
    security_enabled = true
    mail_enabled     = false
    mail_nickname    = "dagster-users"
}

resource "azuread_application" "auth" {
    display_name     = "oauth2-proxy"
    # sign_in_audience = "AzureADMyOrg" # Others are also supported

    group_membership_claims = [
        # azuread_group.dagster.display_name
        "SecurityGroup"
    ]

    web {
        redirect_uris = [
            "https://dagster.kevin-mcquate.net/",
        ]
    }
    // We don't specify any required API permissions - we allow user consent only
}

resource "azuread_service_principal" "sp" {
    client_id                    = azuread_application.auth.client_id
    app_role_assignment_required = false
}

resource "azuread_service_principal_password" "pass" {
    service_principal_id = azuread_service_principal.sp.id
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "main-vault-4rf5tgwer2"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = azuread_service_principal.sp.object_id

#     secret_permissions = [
#       "Get",
#       "List"
#     ]
#   }
}
