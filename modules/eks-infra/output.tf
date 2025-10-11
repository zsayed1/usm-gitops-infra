##############################
# VPC Outputs
##############################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The list of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "The list of public subnets"
  value       = module.vpc.public_subnets
}

##############################
# EKS Outputs
##############################
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_oidc_issuer" {
  description = "The OIDC issuer URL associated with the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

##############################
# ECR Outputs
##############################
output "ecr_app_repo_url" {
  description = "URL of the ECR app image repository"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_helm_repo_url" {
  description = "URL of the ECR Helm repository"
  value       = aws_ecr_repository.helm_repo.repository_url
}

##############################
# IAM & GitHub OIDC Outputs
##############################
output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
