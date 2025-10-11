provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_infra.eks_cluster_name
}

provider "kubernetes" {
  host                   = module.eks_infra.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_infra.cluster_certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks_infra.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_infra.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}