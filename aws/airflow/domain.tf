
data "aws_route53_zone" "primary" {
  name = var.domain
}

locals {
    airflow_domain = "airflow.${var.domain}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.airflow_domain
  type    = "A"
  ttl     = 300
  records = [module.airflow.public_ip]
}