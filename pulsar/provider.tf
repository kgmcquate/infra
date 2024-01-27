
terraform {
  required_providers {
    pulsar = {
      source = "streamnative/pulsar"
      version = ">= 0.2.3"
    }
  }
}

provider pulsar {
    web_service_url = "http://pulsar.kevin-mcquate.net:8080"
    token           = var.pulsar_jwt_token
}
