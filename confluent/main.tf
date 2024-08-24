variable "confluent_cloud_api_key" {
  description = "The Confluent Cloud API Key"
}

variable "confluent_cloud_api_secret" {
  description = "The Confluent Cloud API Secret"
}

variable aws_region {
  description = "The AWS region to deploy the Confluent Cloud cluster"
}

# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_service_account" "kafka" {
  display_name = "kafka-service-account"

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_role_binding" "kafka_cloud_admin" {
  principal   = "User:${confluent_service_account.kafka.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.main.rbac_crn
}


resource "confluent_kafka_acl" "kafka_acl" {

  for_each = {
    raw_video_frames = confluent_kafka_topic.raw_video_frames.topic_name
    processed_video_frames = confluent_kafka_topic.processed_video_frames.topic_name
    processed_video_frames_counts = confluent_kafka_topic.processed_video_frames_counts.topic_name
  }

  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }
  resource_type = "TOPIC"
  resource_name = each.value
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.kafka.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint
  credentials {
    key    = confluent_api_key.kafka_api_key.id
    secret = confluent_api_key.kafka_api_key.secret
  }
}

resource "confluent_api_key" "kafka_api_key" {
  display_name = "kafka_api_key"

  owner {
    id          = confluent_service_account.kafka.id
    api_version = confluent_service_account.kafka.api_version
    kind        = confluent_service_account.kafka.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.main.id
    api_version = confluent_kafka_cluster.main.api_version
    kind        = confluent_kafka_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }
}

resource "confluent_environment" "main" {
  display_name = "main"

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_cluster" "main" {
  display_name = "main_kafka_cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  basic {}

  environment {
    id = confluent_environment.main.id
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_topic" "raw_video_frames" {
  topic_name = "raw-video-frames"
  partitions_count = 4

  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  credentials {
    key    = confluent_api_key.kafka_api_key.id
    secret = confluent_api_key.kafka_api_key.secret
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_topic" "processed_video_frames" {
  topic_name = "processed-video-frames"
  partitions_count = 4

  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  credentials {
    key    = confluent_api_key.kafka_api_key.id
    secret = confluent_api_key.kafka_api_key.secret
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_topic" "processed_video_frames_counts" {
  topic_name = "processed-video-frames-counts"
  partitions_count = 4

  rest_endpoint = confluent_kafka_cluster.main.rest_endpoint
  kafka_cluster {
    id = confluent_kafka_cluster.main.id
  }

  credentials {
    key    = confluent_api_key.kafka_api_key.id
    secret = confluent_api_key.kafka_api_key.secret
  }

  lifecycle {
    prevent_destroy = true
  }
}