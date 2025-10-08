#########################################
# 1️⃣ VPC – Networking Layer
#########################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "usm-${var.env}-vpc"
  cidr    = var.vpc_cidr
  azs     = var.azs

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, {
    Environment = var.env
    Layer       = "network"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24.0"

  cluster_name    = "${var.cluster_base_name}-${var.env}"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true # IRSA

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  eks_managed_node_groups = {
    default = {
      desired_size   = var.node_count
      min_size       = 1
      max_size       = var.node_count + 1
      instance_types = [var.instance_type]
      capacity_type  = "ON_DEMAND"

      labels = {
        Environment = var.env
        NodeGroup   = "default"
      }

      tags = {
        Name = "${var.cluster_base_name}-${var.env}-nodegroup"
      }
    }
  }

  tags = merge(var.tags, {
    Environment = var.env
    Cluster     = "${var.cluster_base_name}-${var.env}"
    Layer       = "platform"
  })
}


###############################################################
# AWS-AUTH SUBMODULE for EKS v20.x
###############################################################

data "aws_caller_identity" "current" {}

# module "aws_auth" {
#   # Pin to the same 20.x series as your EKS module
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/aws-auth?ref=v20.24.0"


#   # Make sure it runs after the EKS cluster is created
#   depends_on = [module.eks]

#   ###############################################################
#   # Link this ConfigMap to your cluster
#   ###############################################################
#   eks_cluster_name                       = module.eks.cluster_name
#   eks_cluster_endpoint                   = module.eks.cluster_endpoint
#   eks_cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

#   ###############################################################
#   # USERS – grant admin rights
#   ###############################################################
#   aws_auth_users = [
#     {
#       # Whoever runs Terraform (usually terraform-user)
#       userarn  = data.aws_caller_identity.current.arn
#       username = "cluster-creator"
#       groups   = ["system:masters"]
#     },
#     {
#       # Optionally give Zeshan permanent admin access too
#       userarn  = "arn:aws:iam::879381282588:user/zeshan.sayed"
#       username = "zeshan"
#       groups   = ["system:masters"]
#     }
#   ]

#   ###############################################################
#   # ROLES – allow nodegroups to join the cluster
#   ###############################################################
#   aws_auth_roles = [
#     {
#       rolearn  = module.eks.node_groups["default"].iam_role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups   = ["system:bootstrappers", "system:nodes"]
#     }
#   ]
# }
