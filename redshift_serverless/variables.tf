
variable admin_user_password {sensitive = true}

variable security_group_ids { 
    type = list(string)
}
variable subnet_ids {
  type = list(string)
}