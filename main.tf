
variable POSTGRES_PWD {
  type = string
}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
    region = data.aws_caller_identity.current.region
}


resource "aws_s3_bucket" "test-bucket" {
  bucket = "deployment-zone-${local.account_id}-${local.region}"
}
