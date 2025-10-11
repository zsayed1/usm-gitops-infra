##############################
# 🌐 VPC Outputs
##############################

output "vpc_id" {
  description = "The ID of the VPC created by the module"
  value       = module.eks_infra.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs created by the VPC module"
  value       = module.eks_infra.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs created by the VPC module"
  value       = module.eks_infra.public_subnets
}

##############################
# ☸️ EKS Outputs
##############################

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_infra.eks_cluster_name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks_infra.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster API server"
  value       = module.eks_infra.eks_cluster_endpoint
}

output "eks_cluster_oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.eks_infra.eks_cluster_oidc_issuer
}

output "node_security_group_id" {
  description = "Security group ID of the EKS managed node group"
  value       = module.eks_infra.node_security_group_id
}

##############################
# 📦 ECR Outputs
##############################

output "ecr_app_repo_url" {
  description = "The repository URL of the application ECR"
  value       = module.eks_infra.ecr_app_repo_url
}

output "ecr_helm_repo_url" {
  description = "The repository URL of the Helm chart ECR"
  value       = module.eks_infra.ecr_helm_repo_url
}

##############################
# 🔐 GitHub OIDC / IAM Outputs
##############################

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC identity provider"
  value       = module.eks_infra.github_oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions"
  value       = module.eks_infra.github_actions_role_arn
}
