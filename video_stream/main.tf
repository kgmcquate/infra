variable subnet_ids {}
variable vpc_id {}
variable security_group_ids {}
variable availability_zones {}
variable ssh_keypair {}
variable jwt_secret_key_base64 {}
variable jwt_token {}

module pulsar_cluster {
    source = "./pulsar_cluster"
    subnet_ids = var.subnet_ids
    availability_zones = var.availability_zones
    security_group_ids = var.security_group_ids
    vpc_id = var.vpc_id
    ssh_keypair = var.ssh_keypair
    jwt_secret_key_base64 = var.jwt_secret_key_base64
}

module pulsar {
    source = "./pulsar"
    broker_host = module.pulsar_cluster.broker_host
    broker_port = module.pulsar_cluster.broker_port
    superuser_name = module.pulsar_cluster.superuser_name
    cluster_name = module.pulsar_cluster.cluster_name
    jwt_token = var.jwt_token
    # depends_on = [ module.pulsar_cluster ]
}