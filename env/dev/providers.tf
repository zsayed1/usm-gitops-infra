provider "aws" {
  region = var.region
}

# --- EKS Data Sources ---
data "aws_eks_cluster" "this" {
  name = "${var.namespace}-${var.env}-eks"
}

data "aws_eks_cluster_auth" "this" {
  name = "${var.namespace}-${var.env}-eks"
}

provider "kubernetes" {
  host                   = module.eks_infra.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_infra.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_infra.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_infra.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}