module "core" {
  source = "../../modules/core"

  aws_region         = "eu-west-1"
  project_name       = "skillpulse-prod"
  vpc_cidr           = "10.0.0.0/16"
  cluster_version    = "1.31"
  node_instance_type = "c7i-flex.large"
  environment        = "prod"
}
