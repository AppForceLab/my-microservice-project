output "vpc_id" {
  value = module.vpc.vpc_id
}

output "s3_bucket" {
  value = module.s3_backend.s3_bucket
}

output "dynamodb_table" {
  value = module.s3_backend.dynamodb_table
}

output "ecr_url" {
  value = module.ecr.ecr_url
}
