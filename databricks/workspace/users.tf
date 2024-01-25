data "databricks_user" "me" {
  user_name = "kgmcquate@gmail.com"
}

# resource "databricks_entitlements" "me" {
#   user_id                    = data.databricks_user.me.id
#   allow_cluster_create       = true
#   allow_instance_pool_create = true
#   workspace_access = true
# }

resource "databricks_mws_permission_assignment" "add_user" {
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_user.me.id
  permissions  = ["USER"] # ["ADMIN"]#
}

# resource "databricks_permission_assignment" "add_user" {
#   principal_id = data.databricks_user.me.id
#   permissions  = ["USER"]
# }