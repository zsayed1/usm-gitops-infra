########################
# VPC Outputs
########################

output "vpc_id" {
  description = "ID of the VPC created for the EKS cluster."
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of private subnet IDs."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs."
  value       = module.vpc.public_subnets
}

########################
# ☸️ EKS Outputs
########################

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "API server endpoint of the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "The Kubernetes version of the EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_oidc_issuer" {
  description = "The OIDC issuer URL for the EKS cluster."
  value       = module.eks.cluster_oidc_issuer_url
}

########################
# ECR Outputs
########################

output "ecr_app_repository_url" {
  description = "The URL of the ECR repository for application Docker images."
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecr_helm_repository_url" {
  description = "The URL of the ECR OCI repository for Helm charts."
  value       = aws_ecr_repository.helm_repo.repository_url
}

########################
# 🔐 GitHub OIDC IAM Outputs
########################

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role GitHub Actions assumes to push to ECR."
  value       = aws_iam_role.github_actions.arn
}

########################
# Node Group Info
########################

output "eks_node_group_arns" {
  description = "List of ARNs for the EKS managed node groups."
  value       = [for ng in module.eks.eks_managed_node_groups : ng.node_group_arn]
}

# output "eks_node_group_names" {
#   description = "List of EKS managed node group names."
#   value       = [for ng in module.eks.eks_managed_node_groups : ng.node_group_name]
# }
