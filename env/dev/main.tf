module "eks_infra" {
  source = "../../modules/eks-infra"

  env                     = var.env
  namespace              = var.namespace
  region                 = var.region

  vpc_cidr              = var.vpc_cidr
  private_subnets       = var.private_subnets
  public_subnets        = var.public_subnets
  azs                   = var.azs
  enable_flow_logs           = var.enable_flow_logs
  flow_log_traffic_type      = var.flow_log_traffic_type
  flow_log_log_group_name    = var.flow_log_log_group_name
  flow_log_retention_in_days = var.flow_log_retention_in_days

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


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = data.aws_eks_node_group.default.node_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])

    mapUsers = yamlencode([
      {
        userarn  = "arn:aws:iam::${var.account_id}:user/terraform-user"
        username = "terraform-user"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [module.eks_infra]
}

