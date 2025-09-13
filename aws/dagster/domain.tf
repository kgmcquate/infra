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
  dagster_webserver_ip = "45.55.116.117"
  dagster_domain = "k8s-dashboard.${var.base_domain}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.dagster_domain
  type    = "A"
  ttl     = 300
  records = [local.dagster_webserver_ip]
}