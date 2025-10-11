##############################
# Global Settings
##############################

variable "namespace" {
  description = "Project or application namespace (e.g., myapp)"
  type        = string
  default     = "myapp"

  validation {
    condition     = length(var.namespace) > 2
    error_message = "Namespace must be at least 3 characters long."
  }
}

variable "region" {
  description = "Project or application namespace (e.g., myapp)"
  type        = string
  default     = "us-east-1"

}

variable "stage" {
  description = "Deployment stage (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.stage)
    error_message = "Stage must be one of: dev, staging, prod."
  }
}

variable "env" {
  description = "Environment name (e.g., dev, qa, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = length(var.env) > 1
    error_message = "Environment name must be at least 2 characters long."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

##############################
# VPC Settings
##############################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.azs) >= 2
    error_message = "You must specify at least 2 availability zones."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = alltrue([for subnet in var.private_subnets : can(cidrnetmask(subnet))])
    error_message = "Each private subnet must be a valid CIDR block."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]

  validation {
    condition     = alltrue([for subnet in var.public_subnets : can(cidrnetmask(subnet))])
    error_message = "Each public subnet must be a valid CIDR block."
  }
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 14

  validation {
    condition     = var.flow_log_retention_days >= 1 && var.flow_log_retention_days <= 365
    error_message = "Flow log retention days must be between 1 and 365."
  }
}

##############################
# EKS Settings
##############################

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"

  validation {
    condition     = can(regex("^1\\.(2[5-9]|3[0-9])$", var.cluster_version))
    error_message = "Cluster version must be 1.25 or newer (e.g., 1.29)."
  }
}

variable "node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "You must specify at least one instance type."
  }
}

variable "node_desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 1
    error_message = "Desired node count must be at least 1."
  }
}

variable "node_min_size" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_size >= 0
    error_message = "Min size cannot be negative."
  }
}

variable "node_max_size" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3

  validation {
    condition     = var.node_max_size >= var.node_desired_size
    error_message = "Max size must be >= desired size."
  }
}

variable "node_capacity_type" {
  description = "Capacity type for EKS nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "Capacity type must be ON_DEMAND or SPOT."
  }
}

##############################
# ECR Settings
##############################

variable "ecr_app_name" {
  description = "Name of the ECR repository for application images"
  type        = string
  default     = "myapp-repo"

  validation {
    condition     = length(var.ecr_app_name) > 2
    error_message = "ECR app repo name must be at least 3 characters."
  }
}

variable "ecr_helm_name" {
  description = "Name of the ECR repository for Helm charts"
  type        = string
  default     = "myapp-helm-repo"

  validation {
    condition     = length(var.ecr_helm_name) > 2
    error_message = "ECR Helm repo name must be at least 3 characters."
  }
}

##############################
# GitHub OIDC Settings
##############################

variable "github_oidc_url" {
  description = "GitHub OIDC provider URL"
  type        = string
  default     = "https://token.actions.githubusercontent.com"

  validation {
    condition     = can(regex("^https://", var.github_oidc_url))
    error_message = "GitHub OIDC URL must start with https://"
  }
}

variable "github_oidc_thumbprint" {
  description = "GitHub OIDC thumbprint"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da0ecd0c2c4"

  validation {
    condition     = length(var.github_oidc_thumbprint) == 40
    error_message = "OIDC thumbprint must be 40 hex characters."
  }
}

variable "github_repo_filter" {
  description = "Filter for GitHub repository (e.g., repo:owner/name:ref:refs/heads/main)"
  type        = string
  default     = "repo:myorg/myrepo:ref:refs/heads/main"

  validation {
    condition     = can(regex("^repo:", var.github_repo_filter))
    error_message = "GitHub repo filter must start with 'repo:'."
  }
}
