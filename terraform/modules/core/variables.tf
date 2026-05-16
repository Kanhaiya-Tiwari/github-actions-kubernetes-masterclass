
# Description: Defines input variables for the Terraform configuration.

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "skillpulse"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS."
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "Instance type for EKS worker nodes."
  type        = string
  default     = "t3.medium"
}

variable "environment" {
  description = "The deployment environment (dev, stage, prod)."
  type        = string
  default     = "dev"
}
