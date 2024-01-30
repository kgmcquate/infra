resource "databricks_mws_networks" "this" {
  account_id         = var.databricks_account_id
  network_name       = "${var.name}-network"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
}

resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = var.root_storage_bucket.bucket
  storage_configuration_name = "${var.name}-storage"
}

resource "databricks_mws_credentials" "this" {
  # account_id       = var.databricks_account_id # needed?
  role_arn         = var.cross_account_role_arn
  credentials_name = "${var.name}-creds"
  # depends_on       = [time_sleep.wait]
}



resource "databricks_mws_workspaces" "this" {
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = var.name

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform"
  }
}

# data "databricks_user" "me" {
#   provider = databricks
#   user_name = "kgmcquate@gmail.com"
# }

# resource "databricks_mws_permission_assignment" "add_user" {
#   workspace_id = databricks_mws_workspaces.this.workspace_id
#   principal_id = data.databricks_user.me.id
#   permissions  = ["USER", "ADMIN"] # ["ADMIN"]#
# }