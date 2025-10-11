# # data "aws_eks_cluster" "this" {
# #   name = module.eks.cluster_name
# # }

# # data "aws_eks_cluster_auth" "this" {
# #   name = module.eks.cluster_name
# # }

# data "aws_eks_node_groups" "all" {
#   cluster_name = "${var.namespace}-${var.env}-eks"
# }

# locals {
#   default_node_group = one([for ng in data.aws_eks_node_groups.all.names : ng if startswith(ng, "default")])
# }


# data "aws_eks_node_group" "default" {
#   cluster_name    = "${var.namespace}-${var.env}-eks"
#   node_group_name = local.default_node_group
#   depends_on = [module.eks_infra]
# }