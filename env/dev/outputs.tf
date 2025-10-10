output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_infra.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks_infra.eks_cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.eks_infra.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.eks_infra.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.eks_infra.public_subnets
}

output "ecr_app_repository_url" {
  description = "ECR repository for app images"
  value       = module.eks_infra.ecr_app_repository_url
}

output "ecr_helm_repository_url" {
  description = "ECR repository for Helm charts"
  value       = module.eks_infra.ecr_helm_repository_url
}
