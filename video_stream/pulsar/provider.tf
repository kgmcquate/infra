
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
  }
}

provider pulsar {
    web_service_url = "http://${var.broker_host}:${var.broker_port}" # Use IP from the Ec2 module to create EC2 before running provider # ${local.pulsar_domain}
    token           = var.jwt_token
}
