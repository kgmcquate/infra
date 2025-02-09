# resource "digitalocean_kubernetes_cluster" "dagster" {
#   name   = "dagster-k8s-cluster"
#   region = "nyc2"
#   version = "1.32.1-do.0"

#   node_pool {
#     name       = "worker-pool"
#     size       = "s-1vcpu-2gb"
#     node_count = 1
#   }
# }

# locals {
#   config = digitalocean_kubernetes_cluster.dagster.kube_config[0].raw_config
# }

# resource "local_file" "foo" {
#   content = local.config
#   filename = "kubernetes/config"
# }
