data "databricks_user" "me" {
  provider = databricks
  user_name = "kgmcquate@gmail.com"
}

# resource "databricks_user" "me2" {
#   user_name = "fuzzh3d@gmail.com"
# }

# resource "databricks_entitlements" "me" {
#   provider = databricks_ws
#   user_id                    = data.databricks_user.me.id
#   allow_cluster_create       = true
#   allow_instance_pool_create = true
#   workspace_access = true
# }

# resource "databricks_mws_permission_assignment" "add_user" {
#   provider = databricks-ws
#   workspace_id = module.workspace.workspace_id
#   principal_id = data.databricks_user.me.id
#   permissions  = ["USER"] # ["ADMIN"]#
# }

resource "databricks_permission_assignment" "add_user" {
  provider = databricks-ws
  principal_id = data.databricks_user.me.id
  permissions  = ["USER"]
}