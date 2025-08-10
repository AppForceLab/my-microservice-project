# Standalone RDS module testing configuration
# This file can be used to test RDS module independently

# provider "aws" {
#   region = "eu-west-1"
# }

# # Use existing VPC for testing
# data "aws_vpc" "existing" {
#   filter {
#     name   = "tag:Name"
#     values = ["lesson-8-9-vpc"]  # Adjust based on your VPC name
#   }
# }

# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.existing.id]
#   }
  
#   filter {
#     name   = "tag:Type"
#     values = ["private"]  # Adjust based on your subnet tags
#   }
# }

# data "aws_security_group" "default" {
#   vpc_id = data.aws_vpc.existing.id
#   name   = "default"
# }

# # Test RDS PostgreSQL Instance
# module "test_postgres_rds" {
#   source = "./modules/rds"
  
#   # Basic Configuration
#   use_aurora     = false
#   engine         = "postgres"
#   engine_version = "14.10"
#   instance_class = "db.t3.micro"
  
#   # Database Configuration
#   db_name  = "testdb"
#   username = "testuser"
#   password = "TestPassword123!"
  
#   # Network Configuration
#   vpc_id                      = data.aws_vpc.existing.id
#   subnet_ids                 = data.aws_subnets.private.ids
#   allowed_security_group_ids = [data.aws_security_group.default.id]
  
#   # Environment
#   environment   = "test"
#   project_name  = "rds-test"
  
#   # Test settings
#   skip_final_snapshot = true
#   deletion_protection = false
  
#   tags = {
#     Purpose = "Testing RDS Module"
#   }
# }

# # Test Aurora MySQL Cluster
# module "test_aurora_mysql" {
#   source = "./modules/rds"
  
#   # Basic Configuration
#   use_aurora        = true
#   engine           = "aurora-mysql"
#   engine_version   = "8.0.mysql_aurora.3.02.0"
#   aurora_instance_class = "db.t3.small"  # Smaller for testing
#   aurora_cluster_size   = 1              # Single instance for testing
  
#   # Database Configuration
#   db_name  = "testapp"
#   username = "admin"
#   password = "AuroraTest123!"
  
#   # Network Configuration
#   vpc_id                      = data.aws_vpc.existing.id
#   subnet_ids                 = data.aws_subnets.private.ids
#   allowed_security_group_ids = [data.aws_security_group.default.id]
  
#   # Environment
#   environment   = "test"
#   project_name  = "aurora-test"
  
#   # Test settings
#   skip_final_snapshot = true
#   deletion_protection = false
  
#   tags = {
#     Purpose = "Testing Aurora Module"
#   }
# }

# # Outputs for testing
# output "postgres_test_endpoint" {
#   value = module.test_postgres_rds.database_endpoint
# }

# output "postgres_test_connection" {
#   value     = module.test_postgres_rds.connection_string
#   sensitive = true
# }

# output "aurora_test_endpoint" {
#   value = module.test_aurora_mysql.database_endpoint
# }

# output "aurora_test_connection" {
#   value     = module.test_aurora_mysql.connection_string
#   sensitive = true
# }