provider "aws" {
  region = "eu-west-1"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-lesson-8-9-bucket-${random_id.bucket_suffix.hex}"
  table_name  = "terraform-locks"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_name           = "lesson-8-9-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-8-9-ecr"
  scan_on_push = true
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name     = "lesson-8-9-eks-cluster"
  cluster_version  = "1.28"
  
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  private_subnet_ids  = module.vpc.private_subnet_ids
  
  node_group_name     = "lesson-8-9-nodes"
  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_max_size       = 4
  node_min_size       = 1
}

module "jenkins" {
  source = "./modules/jenkins"
  
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  
  namespace            = "jenkins"
  release_name         = "jenkins"
  admin_user          = "admin"
  admin_password      = "admin123"
  ecr_repository_url  = module.ecr.ecr_url
  ecr_region          = "eu-west-1"
}

module "argo_cd" {
  source = "./modules/argo_cd"
  
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  
  namespace          = "argocd"
  release_name       = "argocd"
  git_repository_url = "https://github.com/your-username/helm-charts"
  git_path          = "charts"
  target_revision   = "main"
}

# Example: RDS Instance (PostgreSQL)
module "postgres_rds" {
  source = "./modules/rds"
  
  # Basic Configuration
  use_aurora     = false
  engine         = "postgres"
  engine_version = "14.18"
  instance_class = "db.t3.micro"
  
  # Database Configuration
  db_name  = "myapp"
  username = "dbadmin"
  password = "MySecretPassword123!"
  
  # Network Configuration
  vpc_id                        = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnet_ids
  allowed_security_group_ids   = [module.eks.cluster_security_group_id]
  
  # Environment
  environment   = "dev"
  project_name  = "lesson-db-module"
  
  # Storage Configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  # Backup Configuration
  backup_retention_period = 7
  skip_final_snapshot    = true
  
  # High Availability
  multi_az = false
  
  tags = {
    Type = "PostgreSQL"
    Team = "DevOps"
  }
}

# Example: Aurora Cluster (MySQL) - Commented out for initial testing
# module "mysql_aurora" {
#   source = "./modules/rds"
#   
#   # Basic Configuration
#   use_aurora        = true
#   engine           = "aurora-mysql"
#   engine_version   = "8.0.mysql_aurora.3.02.0"
#   aurora_instance_class = "db.r5.large"
#   aurora_cluster_size   = 2
#   
#   # Database Configuration
#   db_name  = "webapp"
#   username = "admin"
#   password = "AuroraSecretPass123!"
#   
#   # Network Configuration
#   vpc_id                        = module.vpc.vpc_id
#   subnet_ids                   = module.vpc.private_subnet_ids
#   allowed_security_group_ids   = [module.eks.cluster_security_group_id]
#   
#   # Environment
#   environment   = "dev"
#   project_name  = "lesson-db-module"
#   
#   # Storage Configuration
#   storage_encrypted = true
#   
#   # Backup Configuration
#   backup_retention_period = 7
#   skip_final_snapshot    = true
#   
#   # Monitoring
#   performance_insights_enabled = true
#   monitoring_interval         = 60
#   
#   tags = {
#     Type = "Aurora MySQL"
#     Team = "DevOps"
#   }
# }
