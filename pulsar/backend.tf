terraform {
    # backend "s3" {}

    required_providers {
        pulsar = {
        source = "streamnative/pulsar"
        version = ">= 0.2.3"
        }
    }
}


