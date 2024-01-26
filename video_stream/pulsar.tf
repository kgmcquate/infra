resource pulsar_tenant tenant {
    tenant = "video_stream"
    admin_roles = ["superuser"]
    allowed_clusters = ["cluster-a"]
}