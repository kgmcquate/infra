
variable POSTGRES_PWD {
  type = string
}

module "lake-freeze" {
    source = "./lake-freeze"
    POSTGRES_PWD = var.POSTGRES_PWD
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "deployment-zone-${data.aws_caller_identity.current.account_id}"
}
