variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "cidr_block" {
  description = ""
  type        = string
  default     = "10.4.0.0/16"
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "name" {
  type        = string
  description = "Prefix for use in the generated names"
}
