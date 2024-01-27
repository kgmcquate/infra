variable broker_host {}
variable broker_port {}
variable superuser_name {}
variable cluster_name {}
variable jwt_token {}

# resource pulsar_tenant tenant {
#     tenant = "video_stream"
#     admin_roles = [var.superuser_name]
#     allowed_clusters = [var.cluster_name]

#     depends_on = [ var.broker_host ]
# }

# resource pulsar_namespace namespace {
#     tenant = "video_stream"
#     namespace = "video_stream"
#     # permission_grant = {
#     #     actions = ["create"]
#     #     role = "superuser"
#     # }
#     depends_on = [ pulsar_tenant.tenant, var.broker_host ]
    
# }

# resource pulsar_topic raw_frames {
#     tenant = "video_stream"
#     namespace = "video_stream"
#     topic_name = "raw-livestream-frames"
#     topic_type = "persistent"
#     partitions = 4
#     depends_on = [ pulsar_tenant.tenant, pulsar_namespace.namespace ]
# }
