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
  dagster_webserver_ip = "138.197.252.141"
  dagster_domain = "dagster.${var.base_domain}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.dagster_domain
  type    = "A"
  ttl     = 300
  records = [local.dagster_webserver_ip]
}

resource "aws_route53_record" "monitoring" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dagster-monitoring.${var.base_domain}"
  type    = "A"
  ttl     = 300
  records = [local.dagster_webserver_ip]
}