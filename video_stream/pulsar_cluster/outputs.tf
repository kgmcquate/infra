output broker_host {
    value = module.video_stream_pulsar.public_ip
}
output broker_port {
    value = local.broker_port
}
output superuser_name {
    value = local.superuser_name
}
output cluster_name {
    value = local.cluster_name
}
