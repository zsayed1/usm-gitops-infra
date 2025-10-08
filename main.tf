module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name   = "usm-${var.env}-vpc"
  cidr   = var.vpc_cidr
  azs    = var.azs

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
  version = "~> 20.0"

  cluster_name    = "${var.cluster_base_name}-${var.env}"
  cluster_version = var.cluster_version

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true   # IRSA

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
