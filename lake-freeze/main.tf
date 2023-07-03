

variable POSTGRES_PWD {
  type = string
}

variable vpc_id {
  type = string
}

variable private_subnet_ids {
  type = list #of strings
}

variable public_subnet_ids {
  type = list #of strings
}