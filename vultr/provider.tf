provider "vultr" {
  api_key = var.api_key
  rate_limit = 100
  retry_limit = 3
}

provider "helm" {
  kubernetes {
    config_path = local_file.foo.filename
  }
}