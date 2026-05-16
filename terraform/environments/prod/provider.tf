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

provider "kubernetes" {
  host                   = module.core.cluster_endpoint
  cluster_ca_certificate = base64decode(module.core.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.core.cluster_name, "--region", "eu-west-1"]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.core.cluster_endpoint
    cluster_ca_certificate = base64decode(module.core.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.core.cluster_name, "--region", "eu-west-1"]
      command     = "aws"
    }
  }
}
