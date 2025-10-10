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

resource "kubernetes_cluster_role_binding" "terraform_admin" {
  metadata {
    name = "terraform-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::${var.account_id}:user/terraform-user"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [kubernetes_config_map.aws_auth]
}
