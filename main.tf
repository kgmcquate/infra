module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
    vpc_id = module.vpc.vpc_id
    subnet_id = module.vpc.private_subnets[0]

    depends_on = [ module.vpc ]
}


variable POSTGRES_PWD {
  type = string
}

data "aws_region" "current" {}
