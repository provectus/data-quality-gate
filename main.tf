data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"
  tags = {
    Module     = "data-qa-gate"
    Environment = var.environment
    Terraform   = "true"
  }
}


resource "aws_cloudwatch_log_group" "state-machine-log-group" {
  name              = "/aws/${local.resource_name_prefix}/states/fast-data-qa-logs"
  retention_in_days = 0
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.current.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
