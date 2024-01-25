variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID"
}

variable cross_account_role_arn {}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "name" {
  type        = string
  description = "Prefix for use in the generated names"
}

variable root_storage_bucket {}

variable security_group_id {}
variable subnet_ids {}
variable vpc_id {}