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
