terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
      version = "0.82.0"
    }
  }
}

provider "snowflake" {
  account                = var.provider_account # required if not using profile. Can also be set via SNOWFLAKE_ACCOUNT env var
  user                   = var.provider_username # required if not using profile or token. Can also be set via SNOWFLAKE_USER env var
  password               = var.provider_password
  role = "ACCOUNTADMIN"
}
