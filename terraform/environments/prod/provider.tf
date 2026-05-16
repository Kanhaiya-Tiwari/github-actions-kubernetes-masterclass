terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "skillpulse-terraform-state-815210276744"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "skillpulse-terraform-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.core.cluster_name
}

provider "kubernetes" {
  host                   = module.core.cluster_endpoint
  cluster_ca_certificate = base64decode(module.core.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.core.cluster_endpoint
    cluster_ca_certificate = base64decode(module.core.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
