variable "env" {
  description = "Environment name (e.g., dev, stage, prod)"
  type        = string

  validation {
    condition     = can(regex("^(dev|stage|prod)$", var.env))
    error_message = "Environment must be one of: dev, stage, or prod."
  }
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR, e.g., 10.0.0.0/16."
  }
}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

}

variable "private_subnets" {
  description = "List of private subnet CIDRs for EKS worker nodes"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs for NAT/LoadBalancers"
  type        = list(string)

}

#########################################
# VPC Configuration Flags
#########################################

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway across all AZs (cost-saving)"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC (required for EKS)"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution support in the VPC (required for EKS)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Owner       = "usmobile-devops"
    Application = "gitops"
    ManagedBy   = "terraform"
  }
}

#########################################
# EKS Configuration
#########################################

variable "cluster_base_name" {
  description = "Base name for the EKS cluster; env suffix appended automatically"
  type        = string
  default     = "usmobile-eks"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "node_count" {
  description = "Desired node count for default node group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}