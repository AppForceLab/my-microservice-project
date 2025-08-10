# Aurora PostgreSQL testing configuration
# PostgreSQL RDS testing completed successfully - now testing Aurora
module "aurora_postgresql_test" {
  source = "./modules/rds"
  
  # Aurora Configuration
  use_aurora        = true
  engine           = "aurora-postgresql"
  engine_version   = "14.12"  # Use compatible version
  aurora_instance_class = "db.t3.medium"  # Smallest Aurora-compatible class
  aurora_cluster_size   = 1               # Single instance for cost efficiency
  
  # Database Configuration
  db_name  = "auroratest"
  username = "auroraadmin"
  password = "AuroraPostgresTest123!"
  
  # Network Configuration (reuse existing VPC)
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  
  # Environment
  environment   = "test"
  project_name  = "aurora-pg-test"
  
  # Cost optimization settings
  backup_retention_period = 1
  skip_final_snapshot    = true
  deletion_protection    = false
  performance_insights_enabled = false
  monitoring_interval    = 0
  
  tags = {
    Purpose = "Aurora PostgreSQL Testing"
    Type    = "Aurora PostgreSQL"
    Cost    = "Minimal"
  }
}

# Outputs for Aurora testing
output "aurora_postgresql_writer_endpoint" {
  value       = module.aurora_postgresql_test.aurora_cluster_endpoint
  description = "Aurora PostgreSQL writer endpoint"
}

output "aurora_postgresql_reader_endpoint" {
  value       = module.aurora_postgresql_test.aurora_cluster_reader_endpoint  
  description = "Aurora PostgreSQL reader endpoint"
}

output "aurora_postgresql_connection" {
  value       = module.aurora_postgresql_test.connection_string
  sensitive   = true
  description = "Aurora PostgreSQL connection string"
}