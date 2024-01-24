output "root_storage_bucket" {
  value = aws_s3_bucket.root_storage_bucket
}

output default_security_group_id {
  value = module.vpc.default_security_group_id
}

output private_subnets {
  value = module.vpc.private_subnets
}

output public_subnets {
  value = module.vpc.public_subnets
}


output vpc_id {
  value = module.vpc.vpc_id
}