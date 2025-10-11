##############################
# VPC
##############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name                     = "${var.namespace}-${var.stage}-vpc"
  cidr                     = var.vpc_cidr
  azs                      = var.azs
  private_subnets          = var.private_subnets
  public_subnets           = var.public_subnets
  map_public_ip_on_launch  = true
  enable_dns_support       = true
  enable_dns_hostnames     = true

  enable_nat_gateway       = true
  single_nat_gateway       = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.namespace}-${var.stage}-eks-new" = "shared"
    "kubernetes.io/role/elb" = "1"
    
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.namespace}-${var.stage}-eks-new" = "shared"
    "kubernetes.io/role/internal-elb" = "1"

  }
  enable_flow_log                                = true
  flow_log_traffic_type                          = "ALL"
  flow_log_destination_type                      = "cloud-watch-logs"
  create_flow_log_cloudwatch_log_group           = true
  create_flow_log_cloudwatch_iam_role            = true
  flow_log_cloudwatch_log_group_retention_in_days = var.flow_log_retention_days

  tags = merge({
    Environment = var.stage
    Terraform   = "true"
  }, var.tags)
}

data "aws_caller_identity" "current" {}

##############################
# VPC
##############################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.3.2"

  name                = "${var.namespace}-${var.stage}-eks-new"
  kubernetes_version  = var.cluster_version

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = concat(module.vpc.private_subnets, module.vpc.public_subnets)

  enable_irsa         = true
  addons = {
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
    kube-proxy = { most_recent = true }
    coredns     = { most_recent = true }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
  }

  endpoint_public_access                   = true
  endpoint_private_access                  = true
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled = true
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      capacity_type  = var.node_capacity_type
      subnet_ids     = module.vpc.private_subnets
    }
  }

  tags = merge({
    Environment = var.stage
    Terraform   = "true"
  }, var.tags)
}

##############################
# ECR for App Images
##############################
resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

##############################
# ECR for Helm Charts (OCI)
##############################
resource "aws_ecr_repository" "helm_repo" {
  name                 = var.ecr_helm_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

##############################
# GitHub OIDC Provider
##############################
resource "aws_iam_openid_connect_provider" "github" {
  url             = var.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.github_oidc_thumbprint]
}

##############################
# IAM Role for GitHub Actions OIDC
##############################
resource "aws_iam_role" "github_actions" {
  name = "${var.namespace}-${var.env}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.github_repo_filter
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_ecr_policy" {
  name        = "${var.namespace}-${var.env}-github-ecr-policy"
  description = "Allows GitHub Actions to push Docker and Helm images to ECR"
  policy      = data.aws_iam_policy_document.github_ecr_policy.json
}

resource "aws_iam_role_policy_attachment" "github_attach_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}

data "aws_iam_policy_document" "github_ecr_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:BatchDeleteImage"
    ]
    resources = ["*"]
  }
}