variable "api_key" {
  type = string
}

# resource "vultr_kubernetes" "main" {
#   region  = "ewr"
#   label   = "main"
#   version = "v1.32.1+1"

#   node_pools {
#     node_quantity = 1
#     plan          = "vc2-2c-4gb"
#     label         = "main-nodepool"
#     auto_scaler   = false
#     min_nodes     = 1
#     max_nodes     = 1
#   }
# }

# resource "local_file" "foo" {
#   content_base64 = vultr_kubernetes.main.kube_config
#   filename = "kubernetes/kubectl.conf"
# }


# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://helm.nginx.com/stable"
#   chart      = "nginx-ingress"
#   namespace  = "nginx-ingress"
#   create_namespace = true
#   # version = ""
# }
#


# output "kubectl_config" {
#   value = vultr_kubernetes.main.kube_config
#   sensitive = true
# }