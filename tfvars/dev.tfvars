env = "dev"
vpc_cidr = "10.0.0.0/16"
azs = ["us-east-1a", "us-east-1b"] #, "us-east-1c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # "10.0.103.0/24"]

tags = {
  Owner       = "usmobile-devops"
  Application = "gitops"
}

#########################################
# EKS Configuration
#########################################
cluster_base_name = "usm-eks"
cluster_version   = "1.30"
node_count        = 2
instance_type     = "t3.medium"