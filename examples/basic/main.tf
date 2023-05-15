provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform = true
    }
  }
}

provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.current.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  resource_name_prefix = "provectus-infra"

  cidr                 = "172.21.0.0/16"
  private_subnets_cidr = ["172.21.16.0/20"]
  public_subnets_cidr  = ["172.21.32.0/20"]
  azs                  = data.aws_availability_zones.available.zone_ids
}

module "data_qa" {
  source = "../../terraform"

  data_test_storage_bucket_name = "dqg-settings-dev"
  environment                   = "demo"
  project                       = "provectus"

  allure_report_image_uri = module.docker_image_allure_report.image_uri
  data_test_image_uri     = module.docker_image_data_test.image_uri
  push_report_image_uri   = module.docker_image_push_report.image_uri

  data_reports_notification_settings = {
    channel     = var.slack_channel
    webhook_url = var.slack_webhook_url
  }

  lambda_private_subnet_ids = module.vpc.private_subnet_ids
  lambda_security_group_ids = module.vpc.security_group_ids

  reports_vpc_id        = module.vpc.vpc_id
  reports_subnet_id     = module.vpc.public_subnet_ids[0]
  reports_whitelist_ips = ["195.155.100.203/32"]
}

module "data_qa_intg" {
  source = "../../terraform"

  data_test_storage_bucket_name = "dqg-settings-intg"
  environment                   = "intg"
  project                       = "provectus"

  allure_report_image_uri = module.docker_image_allure_report.image_uri
  data_test_image_uri     = module.docker_image_data_test.image_uri
  push_report_image_uri   = module.docker_image_push_report.image_uri

  data_reports_notification_settings = {
    channel     = var.slack_channel
    webhook_url = var.slack_webhook_url
  }

  lambda_private_subnet_ids = module.vpc.private_subnet_ids
  lambda_security_group_ids = module.vpc.security_group_ids

  reports_vpc_id        = module.vpc.vpc_id
  reports_subnet_id     = module.vpc.public_subnet_ids[0]
  reports_whitelist_ips = ["195.155.100.203/32"]
}
