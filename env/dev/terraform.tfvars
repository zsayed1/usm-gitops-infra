# -----------------------------
# Environment & Naming
# -----------------------------
env        = "dev"
namespace  = "usm"
region     = "us-east-1"
account_id = "879381282588"
# -----------------------------
# Networking
# -----------------------------
vpc_cidr        = "10.50.0.0/16"
private_subnets = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
public_subnets  = ["10.50.101.0/24", "10.50.102.0/24", "10.50.103.0/24"]
azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]

enable_flow_logs           = true
flow_log_traffic_type      = "ALL"
flow_log_log_group_name    = "/aws/vpc/flow-logs"
flow_log_retention_in_days = 30  

# -----------------------------
# ECR (App & Helm Repos)
# -----------------------------
ecr_app_name  = "usm-apps"
ecr_helm_name = "helm/usm-apps"

# -----------------------------
# GitHub OIDC Integration
# -----------------------------
github_oidc_url        = "https://token.actions.githubusercontent.com"
github_oidc_thumbprint = "6938fd4d98bab03faadb97b34396831e3780aea1"
github_repo_filter     = "repo:zsayed1/usm-app:*"   # 👈 update with your org/repo

# -----------------------------
# EKS Node Group Config
# -----------------------------
eks_managed_node_groups = {
  default = {
    name           = "default"
    instance_types = ["t3.large"]
    desired_size   = 3
    min_size       = 2
    max_size       = 5
    capacity_type  = "ON_DEMAND"
  }
}

# -----------------------------
# Cluster Config
# -----------------------------
cluster_version = "1.30"
