provider "aws" {
  region = "us-east-1"

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

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "dqg-settings"
  environment                   = "demo"

  allure_report_image_uri = module.docker_image_allure_report.image_uri
  data_test_image_uri     = module.docker_image_data_test.image_uri
  push_report_image_uri   = module.docker_image_push_report.image_uri
}

