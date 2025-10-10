output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS cluster endpoint"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnets"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Public subnets"
}

output "ecr_app_repository_url" {
  value       = aws_ecr_repository.usm_app.repository_url
  description = "ECR repository URL for the application"
}

output "ecr_helm_repository_url" {
  value       = aws_ecr_repository.usm_app_helm.repository_url
  description = "ECR repository URL for Helm charts"
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_ecr.arn
  description = "ARN of the GitHub Actions IAM role"
}
