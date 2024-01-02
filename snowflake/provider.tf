terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      version = "0.82.0"
    }
  }
}

provider "snowflake" {
  account                = var.provider_account # required if not using profile. Can also be set via SNOWFLAKE_ACCOUNT env var
  username               = var.provider_username # required if not using profile or token. Can also be set via SNOWFLAKE_USER env var
  password               = var.provider_password
}
