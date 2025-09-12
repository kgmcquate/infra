# variable "dagster_webserver_ip" {
#   type = string
# }

variable "base_domain" {
  type = string
}

data "aws_route53_zone" "primary" {
  name = var.base_domain
}

locals {
  dagster_webserver_ip = "159.89.216.169"
  dagster_domain = "dagster.${var.base_domain}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.dagster_domain
  type    = "A"
  ttl     = 300
  records = [local.dagster_webserver_ip]
}