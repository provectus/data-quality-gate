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

  data_test_storage_bucket_name = "dqg-settings-dev"
  environment                   = "demo"
  project                       = "provectus"

  allure_report_image_uri = module.docker_image_allure_report.image_uri
  data_test_image_uri     = module.docker_image_data_test.image_uri
  push_report_image_uri   = module.docker_image_push_report.image_uri

  web_acl_id = "arn:aws:wafv2:us-east-1:024975173233:global/webacl/demo-provectus-web-acl/c4517afa-629f-41ab-a4b9-a9645eb9b8dc"

  data_reports_notification_settings = {
    channel     = var.slack_channel
    webhook_url = var.slack_webhook_url
  }
}

module "data_qa_intg" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "dqg-settings-intg"
  environment                   = "intg"
  project                       = "provectus"

  allure_report_image_uri = module.docker_image_allure_report.image_uri
  data_test_image_uri     = module.docker_image_data_test.image_uri
  push_report_image_uri   = module.docker_image_push_report.image_uri

  web_acl_id = "arn:aws:wafv2:us-east-1:024975173233:global/webacl/demo-provectus-web-acl/c4517afa-629f-41ab-a4b9-a9645eb9b8dc"

  data_reports_notification_settings = {
    channel     = var.slack_channel
    webhook_url = var.slack_webhook_url
  }
}
