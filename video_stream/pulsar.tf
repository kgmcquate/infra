resource pulsar_tenant tenant {
    tenant = "video_stream"
    admin_roles = ["superuser"]
    allowed_clusters = ["cluster-a"]
}

resource pulsar_namespace namespace {
    tenant = "video_stream"
    namespace = "video_stream"
    # permission_grant = {
    #     actions = ["create"]
    #     role = "superuser"
    # }
    depends_on = [ pulsar_tenant.tenant ]
    
}

resource pulsar_topic raw_frames {
    tenant = "video_stream"
    namespace = "video_stream"
    topic_name = "raw-livestream-frames"
    topic_type = "persistent"
    partitions = 4
    depends_on = [ pulsar_tenant.tenant, pulsar_namespace.namespace ]
}