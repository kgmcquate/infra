variable "aws_account_id" {
  type = string
}

variable "AWS_REGION" {
    type    = string
}

variable "AWS_ACCESS_KEY_ID" {
    type    = string
}

variable "AWS_SECRET_ACCESS_KEY" {
    type    = string
}

variable "snowflake_account" {
    type    = string
}

variable "snowflake_password" {
  type    = string
}

variable "dbt_testgen_snowflake_password" {
  type    = string
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

variable "confluent_cloud_api_key" {
  description = "The Confluent Cloud API Key"
}

variable "confluent_cloud_api_secret" {
  description = "The Confluent Cloud API Secret"
}

variable "vultr_api_key" {
  type = string
}

variable "digital_ocean_token" {
  type = string
}