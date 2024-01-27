variable broker_host {}
variable broker_port {}
variable superuser_name {}
variable cluster_name {}

resource pulsar_tenant tenant {
    tenant = "video_stream"
    admin_roles = [var.superuser_name]
    allowed_clusters = [var.cluster_name]

    # depends_on = [ module.video_stream_pulsar ]
}

resource pulsar_namespace namespace {
    tenant = "video_stream"
    namespace = "video_stream"
    # permission_grant = {
    #     actions = ["create"]
    #     role = "superuser"
    # }
    # depends_on = [ pulsar_tenant.tenant ]
    
}

# resource pulsar_topic raw_frames {
#     tenant = "video_stream"
#     namespace = "video_stream"
#     topic_name = "raw-livestream-frames"
#     topic_type = "persistent"
#     partitions = 4
#     depends_on = [ pulsar_tenant.tenant, pulsar_namespace.namespace ]
# }
