# AWS GitOps Platform – EKS Infrastructure

- AWS VPC
  - Public Subnets
  - Private Subnets
  - NAT Gateway
  - Flow Logs
- EKS Cluster
  - Managed Node Groups
  - Addons: CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent
- ECR Repositories
  - App Images
  - Helm Charts
- GitHub OIDC Provider
  - IAM Role for GitHub Actions