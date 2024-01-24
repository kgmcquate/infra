variable "AWS_REGION" {
    type    = string
}

variable "AWS_ACCESS_KEY_ID" {
    type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
    type    = string
}

variable POSTGRES_PWD {
  type = string
}

variable snowflake_password {
  type = string
}

variable dbt_testgen_snowflake_password {
  type = string
}

variable dbt_testgen_redshift_password {
  type = string
}

variable databricks_account_id {
  type = string
}

variable databricks_account_client_id {
  type = string
}

variable databricks_account_client_secret {
  type = string
}
