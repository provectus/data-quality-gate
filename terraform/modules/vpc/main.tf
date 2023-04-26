locals {
  resource_name_prefix = "DQG-${var.qualifier}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "DQG-${var.qualifier}-vpc"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets_cidr
}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
    },
    dynamodb = {
      service      = "dynamodb"
      service_type = "Gateway"
    },
    secretsmanager = {
      service             = "secretsmanager"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
  }
}

resource "aws_security_group" "lambda_security_group" {
  name   = "${local.resource_name_prefix}-service-endpoints"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow lambda out to redshift through vpc endpoint"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "Allow lambda out to tcp through vpc endpoint"
  }
}