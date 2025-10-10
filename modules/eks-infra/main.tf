##############################
# VPC
##############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                 = "${var.namespace}-${var.env}-vpc"
  cidr                = var.vpc_cidr
  azs                 = var.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = var.tags
}


##############################
# VPC
##############################

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = var.flow_log_log_group_name
  retention_in_days = var.flow_log_retention_in_days
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  count          = var.enable_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role[0].arn
  traffic_type         = var.flow_log_traffic_type
  vpc_id               = module.vpc.vpc_id
  log_destination_type = "cloud-watch-logs"
  depends_on = [module.vpc] 
}


##############################
# EKS Cluster
##############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                     = "${var.namespace}-${var.env}-eks"
  cluster_version                  = var.cluster_version
  vpc_id                           = module.vpc.vpc_id
  subnet_ids                       = module.vpc.private_subnets
  cluster_endpoint_public_access   = var.cluster_endpoint_public_access
  cluster_endpoint_private_access  = var.cluster_endpoint_private_access
  enable_irsa                      = var.enable_irsa
  cluster_enabled_log_types        = var.cluster_enabled_log_types 
  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.tags
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
# IAM Role for GitHub Actions
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
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
}