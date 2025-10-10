########################
# General Settings
########################
variable "namespace" {
  description = "Project namespace prefix for resources (e.g., usm)"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, stage, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "cluster_version" {
  description = "EKS cluster version (e.g., 1.30)"
  type        = string
}

variable "tags" {
  type = map(string)
  description = "Tags to apply to resources"
  default = {}
}

########################
# Networking / VPC
########################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "The VPC CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "You must provide at least two availability zones."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ"
  type        = bool
  default     = true
}

########################
# EKS Cluster Settings
########################
variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_enabled_log_types" {
  description = "List of control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    capacity_type  = string
  }))
}

########################
# ECR Settings
########################
variable "ecr_app_name" {
  description = "Name of the ECR repository for application Docker images"
  type        = string

  validation {
    condition     = length(var.ecr_app_name) > 1
    error_message = "ECR app repository name cannot be empty."
  }
}

variable "ecr_helm_name" {
  description = "Name of the ECR repository for Helm charts (OCI)"
  type        = string

  validation {
    condition     = length(var.ecr_helm_name) > 1
    error_message = "ECR Helm repository name cannot be empty."
  }
}

########################
# GitHub OIDC Settings
########################

variable "github_oidc_url" {
  description = "OIDC provider URL for GitHub Actions"
  type        = string
}

variable "github_oidc_thumbprint" {
  description = "Thumbprint for GitHub OIDC provider"
  type        = string

}

variable "github_repo_filter" {
  description = "GitHub repo filter for OIDC role assumption (e.g., repo:org/repo:*)"
  type        = string
}


# FLowLogs

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture: ACCEPT, REJECT, or ALL"
  type        = string
  default     = "ALL"
}

variable "flow_log_log_group_name" {
  description = "CloudWatch log group name for VPC Flow Logs"
  type        = string
  default     = "/aws/vpc/flow-logs"
}

variable "flow_log_retention_in_days" {
  description = "Retention period for flow logs in CloudWatch"
  type        = number
  default     = 30
}
