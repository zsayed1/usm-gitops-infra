module "eks_infra" {
  source = "../../modules/eks-infra"

  namespace               = var.namespace
  stage                   = var.stage
  env                     = var.env

  vpc_cidr               = var.vpc_cidr
  azs                    = var.azs
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  flow_log_retention_days = var.flow_log_retention_days

  cluster_version        = var.cluster_version
  node_instance_types    = var.node_instance_types
  node_desired_size      = var.node_desired_size
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  node_capacity_type     = var.node_capacity_type

  ecr_app_name           = var.ecr_app_name
  ecr_helm_name          = var.ecr_helm_name

  github_oidc_url        = var.github_oidc_url
  github_oidc_thumbprint = var.github_oidc_thumbprint
  github_repo_filter     = var.github_repo_filter

  tags                   = var.tags
}
