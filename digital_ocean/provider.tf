variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# provider "helm" {
#   kubernetes {
#     config_path = local_file.foo.filename
#   }
# }