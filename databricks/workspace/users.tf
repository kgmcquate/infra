data "databricks_user" "me" {
  user_name = "kgmcquate@gmail.com"
}

resource "databricks_entitlements" "me" {
  user_id                    = data.databricks_user.me.id
  allow_cluster_create       = true
  allow_instance_pool_create = true
  workspace_access = true
}