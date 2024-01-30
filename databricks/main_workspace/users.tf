

resource "databricks_user" "me2" {
  provider = databricks.main-ws
  user_name = "kgmcquate@gmail.com"
  allow_cluster_create       = true
  allow_instance_pool_create = true
  workspace_access = true
}

# resource "databricks_entitlements" "me" {
#   provider = databricks
#   user_id                    = data.databricks_user.me.id
#   allow_cluster_create       = true
#   allow_instance_pool_create = true
#   workspace_access = true
# }

# variable "admin_user" {
  
# }



resource "databricks_permission_assignment" "add_user" {
  provider = databricks.main-ws
  principal_id = databricks_user.me2.id
  permissions  = ["USER", "ADMIN"]
}