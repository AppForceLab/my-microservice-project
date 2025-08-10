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