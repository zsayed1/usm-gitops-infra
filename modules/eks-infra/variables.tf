##############################
# Global Settings
##############################
variable "namespace" {
  description = "Project or application namespace"
  type        = string
}

variable "stage" {
  description = "Deployment stage (e.g., dev, staging, prod)"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, qa, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

##############################
# VPC Settings
##############################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 14
}

##############################
# EKS Settings
##############################
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3
}

variable "node_capacity_type" {
  description = "Capacity type for EKS nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

##############################
# ECR Settings
##############################
variable "ecr_app_name" {
  description = "Name of the ECR repository for application images"
  type        = string
}

variable "ecr_helm_name" {
  description = "Name of the ECR repository for Helm charts"
  type        = string
}

##############################
# GitHub OIDC Settings
##############################
variable "github_oidc_url" {
  description = "GitHub OIDC provider URL"
  type        = string
}

variable "github_oidc_thumbprint" {
  description = "GitHub OIDC thumbprint"
  type        = string
}

variable "github_repo_filter" {
  description = "Filter for GitHub repository (e.g., repo:owner/name:ref:refs/heads/main)"
  type        = string
}
