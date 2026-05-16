
# Description: Defines the outputs to be displayed after terraform apply.

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "The AWS region where resources are deployed."
  value       = var.aws_region
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}
