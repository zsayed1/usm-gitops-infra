#########################################
# 1️⃣ VPC – Networking Layer
#########################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${var.env}-vpc"
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
