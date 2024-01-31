
resource "databricks_instance_profile" "main_profile" {
  provider = databricks.main-ws
  instance_profile_arn = var.instance_profile_arn
}