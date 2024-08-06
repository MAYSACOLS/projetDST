output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "The public subnets of the VPC"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnets of the VPC"
  value       = module.vpc.private_subnets
}

output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "The security group ID of the EKS nodes"
  value       = aws_security_group.eks_node.id
}
output "wordpress_url" {
  description = "The URL of the WordPress application"
  value       = aws_lb.wordpress.dns_name
}
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "db_instance_endpoint" {
  value       = aws_db_instance.mariadb.endpoint
}

# Output pour obtenir le DNS du Load Balancer
output "lb_dns" {
  value = aws_lb.wordpress.dns_name
  description = "Le DNS du Load Balancer pour WordPress"
}