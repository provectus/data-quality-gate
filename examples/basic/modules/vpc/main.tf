locals {
  resource_name_prefix    = var.resource_name_prefix
  private_route_table_ids = module.vpc.private_route_table_ids
}

data "aws_region" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  enable_dns_hostnames = true

  name = "${local.resource_name_prefix}-vpc"
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr

  map_public_ip_on_launch = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  count = length(local.private_route_table_ids)

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = local.private_route_table_ids[count.index]
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.vpc.vpc_id
  service_name = data.aws_vpc_endpoint_service.dynamodb.service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = length(local.private_route_table_ids)

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = local.private_route_table_ids[count.index]
}

data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = module.vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.secretsmanager.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = [aws_security_group.secretsmanager.id]
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_security_group" "secretsmanager" {
  name        = "${local.resource_name_prefix}-endpoint-secretsmanager"
  description = "Allow inbound traffic to the secretsmanager endpoint"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "secretsmanager_sg_rule_sg" {
  type                     = "ingress"
  security_group_id        = aws_security_group.secretsmanager.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lambda_security_group.id
  description              = "Allow ingress to secretsmanager from security group"
}


resource "aws_security_group" "lambda_security_group" {
  name   = "${local.resource_name_prefix}-service-endpoints"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow out to redshift through vpc endpoint"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow out to tcp through vpc endpoint"
  }
}