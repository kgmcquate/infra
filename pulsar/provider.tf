
terraform {
  required_providers {
    pulsar = {
      source = "streamnative/pulsar"
      version = ">= 0.2.3"
    }
  }
}

provider pulsar {
    web_service_url = "http://pulsar.kevin-mcquate.net" # Use IP from the Ec2 module to create EC2 before running provider # ${local.pulsar_domain}
    token           = var.pulsar_jwt_token
}
