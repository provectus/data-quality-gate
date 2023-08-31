module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.64.0"

  name = "${local.environment}-${local.cluster_name}"

  cidr = local.cidr

  azs             = local.zones
  private_subnets = local.private
  public_subnets  = local.public

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-public"
    KubernetesCluster                             = local.cluster_name
    Environment                                   = local.environment
    Project                                       = local.project
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    Name                                          = "${local.environment}-${local.cluster_name}-private"
    "kubernetes.io/role/elb-internal"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  tags = {
    Name        = "${local.environment}-${local.cluster_name}"
    Environment = local.environment
    Project     = local.project
    Terraform   = "true"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  iam_role_name               = local.cluster_name
  cluster_security_group_name = local.cluster_name

  cluster_endpoint_public_access = true

  subnet_ids  = local.private_subnets
  vpc_id      = module.vpc.vpc_id
  enable_irsa = true

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  cluster_enabled_log_types              = var.cloudwatch_cluster_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_cluster_log_retention_days

  tags = {
    Environment = local.environment
    Project     = local.project
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore         = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      AmazonElasticFileSystemFullAccess    = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess",
      AmazonEC2ContainerRegistryFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    }

    metadata_options = {
      http_endpoint = "enabled"
      http_tokens   = "optional"
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "${local.environment}-${local.cluster_name}"
      min_size     = 1
      max_size     = 2
      desired_size = 1

      launch_template_name = "dqg-eks-self-mng"
      ami_id               = "ami-04b3720c73dd81e28"
      instance_type        = "t3.medium"
    }
  }
}
