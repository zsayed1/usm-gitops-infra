## VPC Outputs ##
output "vpc_id" {
  description = "The ID of the VPC created for this environment"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs used by EKS worker nodes"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs used by NAT and LoadBalancers"
  value       = module.vpc.public_subnets
}