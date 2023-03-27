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

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "dqg-settings"
  environment                   = "demo"
  project                       = "provectus"

  allure_report_image_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/dqg-allure-report:${random_uuid.allure_report.result}"
  data_test_image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/dqg-data-test:${random_uuid.data_test.result}"
  push_report_image_uri   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/dqg-push-report:${random_uuid.push_report.result}"
}

