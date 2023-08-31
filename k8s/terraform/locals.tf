locals {
  zones   = coalescelist(var.availability_zones, data.aws_availability_zones.available.names)
  cidr    = "10.${var.network}.0.0/16"
  private = [for i, _ in local.zones : "10.${var.network}.20${i}.0/24"]
  public  = [for i, _ in local.zones : "10.${var.network}.${i}.0/24"]

  environment     = var.environment
  project         = var.project
  cluster_name    = var.cluster_name
  domain          = ["${local.cluster_name}.${var.domain_name}"]
  private_subnets = module.vpc.private_subnets
}
