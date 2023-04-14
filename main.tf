
variable POSTGRES_PWD {
  type = string
}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}