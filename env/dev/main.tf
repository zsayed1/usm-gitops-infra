module "eks_infra" {
  source = "../../modules/eks-infra"

  env                     = var.env
  namespace              = var.namespace
  region                 = var.region

  vpc_cidr              = var.vpc_cidr
  private_subnets       = var.private_subnets
  public_subnets        = var.public_subnets
  azs                   = var.azs

  ecr_app_name          = var.ecr_app_name
  ecr_helm_name         = var.ecr_helm_name

  github_oidc_url        = var.github_oidc_url
  github_oidc_thumbprint = var.github_oidc_thumbprint
  github_repo_filter     = var.github_repo_filter

  eks_managed_node_groups = var.eks_managed_node_groups
  cluster_version         = var.cluster_version
    tags = merge(var.tags, {
    Environment = var.env
    Terraform   = "true"
  })
}
