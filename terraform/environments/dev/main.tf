module "core" {
  source = "../../modules/core"

  aws_region         = "eu-west-1"
  project_name       = "skillpulse-dev"
  vpc_cidr           = "10.1.0.0/16"
  cluster_version    = "1.31"
  node_instance_type = "c7i-flex.large"
  environment        = "dev"
}
