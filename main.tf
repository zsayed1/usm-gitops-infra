########################
# VPC
########################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.namespace}-${var.stage}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.stage
    Terraform   = "true"
  }
}

########################
# EKS
########################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${var.namespace}-${var.stage}-eks"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # 👇 Enable public endpoint
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.large"]
      desired_size   = 3
      min_size       = 2
      max_size       = 5
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = var.stage
    Terraform   = "true"
  }
}


resource "aws_ecr_repository" "usm_app" {
  name                 = "usm-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name        = "usm-app"
    Environment = var.env
    Layer       = "container-registry"
  })
}

##########################
# GitHub OIDC Provider
##########################

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's OIDC thumbprint
}

##########################
# IAM Role for GitHub Actions to Push to ECR
##########################
resource "aws_iam_role" "github_actions_ecr" {
  name = "${var.namespace}-${var.stage}-github-actions-ecr-role"

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
            # 👇 Replace with your GitHub org and repo
            "token.actions.githubusercontent.com:sub" = "repo:zsayed1/usm-app:*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.namespace}-${var.env}-github-actions-ecr-role"
    Environment = var.env
    Layer       = "iam"
  })
}

##########################
# Policy to Allow ECR Push
##########################
data "aws_iam_policy_document" "github_ecr_policy" {
  statement {
    sid     = "ECRAccess"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:ListImages",
      "ecr:BatchDeleteImage",
      "ecr:DescribeImages",         
      "ecr:BatchGetImage" 
    ]

    resources = [ "*"
    #   "arn:aws:ecr:${var.region}:${var.account_id}:repository/usm-app",
    #   "arn:aws:ecr:${var.region}:${var.account_id}:repository/helm/usm-app"
    ]
  }
}

resource "aws_iam_policy" "github_ecr_policy" {
  name        = "${var.namespace}-${var.stage}-github-ecr-policy"
  description = "Allows GitHub Actions to push Docker images to ECR"
  policy      = data.aws_iam_policy_document.github_ecr_policy.json
}

resource "aws_iam_role_policy_attachment" "github_attach_ecr" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = aws_iam_policy.github_ecr_policy.arn
}


##########################
# Helm Chart OCI Repository
##########################
resource "aws_ecr_repository" "usm_app_helm" {
  name                 = "helm/usm-app"   # 👈 must match what Helm push uses
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name        = "usm-app-helm"
    Environment = var.env
    Layer       = "helm-registry"
  })
}