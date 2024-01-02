
resource "snowflake_warehouse" "dbt_testgen" {
  name           = "dbt_testgen"
  comment        = "Warehouse used for running integration tests for dbt-testgen"
  warehouse_size = "x-small"
  warehouse_type = "STANDARD"
  enable_query_acceleration = false
  auto_resume = true
  auto_suspend = 60 # seconds
  initially_suspended = true
  max_cluster_count = 1
}

resource "snowflake_grant_privileges_to_role" "dbt_testgen" {

  privileges      = ["USAGE"]

  role_name = snowflake_role.dbt_testgen.name

  with_grant_option = false

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.dbt_testgen
  }
}

resource "snowflake_database" "dbt_testgen" {
  name                        = "dbt_testgen"
  comment                     = "Database used for running integration tests for dbt-testgen"
  data_retention_time_in_days = 0
  is_transient = true
}

resource "snowflake_schema" "dbt_testgen" {
  database = snowflake_database.dbt_testgen.name
  name     = "dbt_testgen"
  comment  = "Schema used for running integration tests for dbt-testgen"

  is_transient        = false
  is_managed          = false
  data_retention_days = 1
}

resource "snowflake_schema_grant" "dbt_testgen" {
  database_name = snowflake_database.dbt_testgen.name
  schema_name   = snowflake_schema.dbt_testgen.name

  privilege = "ALL PRIVILEGES"
  roles     = [snowflake_role.dbt_testgen.name]

  on_future         = true
  with_grant_option = false
}

resource "snowflake_user" "dbt_testgen" {
  name         = "dbt_testgen"
  password     = var.dbt_testgen_password

  default_warehouse       = snowflake_warehouse.dbt_testgen.name
  default_role            = snowflake_role.dbt_testgen.name
}

resource "snowflake_role" "dbt_testgen" {
  name    = "dbt_testgen"
}

resource "snowflake_role_grants" "dbt_testgen" {
  role_name = snowflake_role.dbt_testgen.name

  users = [
    snowflake_user.dbt_testgen.name
  ]
}