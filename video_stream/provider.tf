
terraform {
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = ">= 5.0.0"
    }
    pulsar = {
      source = "streamnative/pulsar"
      version = ">= 0.2.3"
    }
    jwt = {
      source = "camptocamp/jwt"
      version = "1.1.0"
    }
  }
}

provider pulsar {
    web_service_url = "http://${module.video_stream_pulsar.public_ip}:${local.broker_port}" #"http://localhost:8080" ${local.pulsar_domain}
    token           = var.jwt_token
}

provider "jwt" {
  # This provider does not require any special configuration.
}
