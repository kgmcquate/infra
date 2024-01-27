variable subnet_ids {}
variable vpc_id {}
variable security_group_ids {}
variable availability_zones {}
variable ssh_keypair {}
variable jwt_secret_key_base64 {}
variable jwt_token {}

module pulsar_cluster {
    source = "./pulsar_cluster"
    subnet_ids = module.vpc.public_subnets
    availability_zones = module.vpc.azs
    security_group_ids = [aws_security_group.allow_all.id]
    vpc_id = module.vpc.vpc_id
    ssh_keypair = aws_key_pair.ssh.key_name
    jwt_secret_key_base64 = var.jwt_secret_key_base64
    jwt_token = var.jwt_token
}

module pulsar {
    source = "./pulsar"
    broker_host = module.pulsar_cluster.broker_host
    broker_port = module.pulsar_cluster.broker_port
    superuser_name = module.pulsar_cluster.superuser_name
    cluster_name = module.pulsar_cluster.cluster_name

    depends_on = [ module.pulsar_cluster ]
}