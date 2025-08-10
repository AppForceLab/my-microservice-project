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

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "jenkins_url" {
  description = "Jenkins service URL"
  value       = module.jenkins.jenkins_url
}

output "jenkins_admin_user" {
  description = "Jenkins admin username"
  value       = module.jenkins.jenkins_admin_user
}

output "jenkins_admin_password" {
  description = "Jenkins admin password"
  value       = module.jenkins.jenkins_admin_password
  sensitive   = true
}

output "argocd_url" {
  description = "Argo CD server URL"
  value       = module.argo_cd.argocd_url
}

output "argocd_admin_user" {
  description = "Argo CD admin username"
  value       = module.argo_cd.argocd_admin_user
}

output "argocd_admin_password" {
  description = "Argo CD initial admin password"
  value       = module.argo_cd.argocd_admin_password
  sensitive   = true
}

# RDS PostgreSQL outputs
output "postgres_rds_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = module.postgres_rds.database_endpoint
}

output "postgres_rds_port" {
  description = "PostgreSQL RDS port"
  value       = module.postgres_rds.database_port
}

output "postgres_rds_database_name" {
  description = "PostgreSQL RDS database name"
  value       = module.postgres_rds.database_name
}

output "postgres_rds_connection_string" {
  description = "PostgreSQL RDS connection string"
  value       = module.postgres_rds.connection_string
  sensitive   = true
}

# Aurora MySQL outputs - Commented out for initial testing
# output "mysql_aurora_writer_endpoint" {
#   description = "MySQL Aurora writer endpoint"
#   value       = module.mysql_aurora.aurora_cluster_endpoint
# }

# output "mysql_aurora_reader_endpoint" {
#   description = "MySQL Aurora reader endpoint"
#   value       = module.mysql_aurora.aurora_cluster_reader_endpoint
# }

# output "mysql_aurora_port" {
#   description = "MySQL Aurora port"
#   value       = module.mysql_aurora.database_port
# }

# output "mysql_aurora_database_name" {
#   description = "MySQL Aurora database name"
#   value       = module.mysql_aurora.database_name
# }

# output "mysql_aurora_connection_string" {
#   description = "MySQL Aurora connection string"
#   value       = module.mysql_aurora.connection_string
#   sensitive   = true
# }

# output "mysql_aurora_cluster_members" {
#   description = "MySQL Aurora cluster members"
#   value       = module.mysql_aurora.aurora_cluster_members
# }