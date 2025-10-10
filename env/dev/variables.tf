#############################
# 🧪 Environment Settings
#############################

variable "env" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string
}

variable "region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace or prefix for resources"
  type        = string
  default     = "usm"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "account_id" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

#############################
# 🌐 Networking
#############################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones to deploy into"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_flow_logs" {
  type        = bool
  default     = true
}

variable "flow_log_traffic_type" {
  type        = string
  default     = "ALL"
}

variable "flow_log_log_group_name" {
  type        = string
  default     = "/aws/vpc/flow-logs"
}

variable "flow_log_retention_in_days" {
  type        = number
  default     = 30
}

#############################
# 🐳 ECR and Helm Repos
#############################

variable "ecr_app_name" {
  description = "ECR repository name for the application"
  type        = string
  default     = "usm-app"
}

variable "ecr_helm_name" {
  description = "Helm repository name inside ECR"
  type        = string
  default     = "helm/usm-app"
}

#############################
# 🔐 GitHub OIDC Settings
#############################

variable "github_oidc_url" {
  description = "GitHub OIDC Provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_oidc_thumbprint" {
  description = "Thumbprint for GitHub OIDC Provider"
  type        = string
  default     = "6938fd4d98bab03faadb97b34396831e3780aea1"
}

variable "github_repo_filter" {
  description = "GitHub repository pattern to allow OIDC auth"
  type        = string
  default     = "repo:zsayed1/usm-app:*"
}

#############################
# ☸️ EKS Node Groups
#############################

variable "eks_managed_node_groups" {
  description = "Map of managed node groups configuration"
  type        = any
}

#############################
# 🏷️ Tags
#############################

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
