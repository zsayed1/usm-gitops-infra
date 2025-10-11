##############################
# Global Settings
##############################
region    = "us-east-1"
namespace = "test"
stage     = "dev"
env       = "dev"

tags = {
  Application = "gitops-platform"
  Owner       = "usmobile-devops"
  Terraform   = "true"
}

##############################
# VPC Settings
##############################
vpc_cidr        = "10.60.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]
private_subnets = ["10.60.1.0/24", "10.60.2.0/24"]
public_subnets  = ["10.60.101.0/24", "10.60.102.0/24"]

flow_log_retention_days = 14

##############################
# EKS Settings
##############################
cluster_version     = "1.32"
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
node_capacity_type  = "ON_DEMAND"

##############################
# ECR Settings
##############################
ecr_app_name  = "usm-app"
ecr_helm_name = "helm-usm-app"

##############################
# GitHub OIDC Settings
##############################
github_oidc_url         = "https://token.actions.githubusercontent.com"
github_oidc_thumbprint  = "9e99a48a9960b14926bb7f3b02e22da0ecd0c2c4"
github_repo_filter      = "repo:zsayed1/usm-app:ref:refs/heads/*"