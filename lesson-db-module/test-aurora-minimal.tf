# Minimal Aurora configuration for testing
# Uncomment this after PostgreSQL RDS testing is complete

# module "test_aurora_minimal" {
#   source = "./modules/rds"
  
#   # Aurora Configuration
#   use_aurora        = true
#   engine           = "aurora-postgresql"
#   engine_version   = "14.10" 
#   aurora_instance_class = "db.t3.medium"  # Cheaper than db.r5.large
#   aurora_cluster_size   = 1               # Single instance for testing
  
#   # Database Configuration
#   db_name  = "testaurora"
#   username = "auroraadmin"
#   password = "AuroraTestPassword123!"
  
#   # Network Configuration (use existing VPC)
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnet_ids
#   allowed_security_group_ids = [module.eks.cluster_security_group_id]
  
#   # Environment
#   environment   = "test"
#   project_name  = "aurora-test"
  
#   # Test/Dev settings to save costs
#   backup_retention_period = 1
#   skip_final_snapshot    = true
#   deletion_protection    = false
#   performance_insights_enabled = false
#   monitoring_interval    = 0
  
#   tags = {
#     Purpose = "Aurora Testing"
#     Type    = "PostgreSQL Aurora"
#   }
# }

# # Outputs for Aurora testing
# # output "aurora_test_endpoint" {
# #   value = module.test_aurora_minimal.aurora_cluster_endpoint
# # }

# # output "aurora_test_reader_endpoint" {
# #   value = module.test_aurora_minimal.aurora_cluster_reader_endpoint
# # }

# # output "aurora_test_connection" {
# #   value     = module.test_aurora_minimal.connection_string
# #   sensitive = true
# # }

# # output "aurora_test_cluster_members" {
# #   value = module.test_aurora_minimal.aurora_cluster_members
# # }