provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform = true
    }
  }
}

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["213.238.187.134/32"]

  data_test_storage_bucket_name = "dqg-settings"
  environment                   = "provectus"

  allure_report_image_uri = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-allure-report:9b25014b-bf0d-79f4-5a88-9619c4ac42bf"
  data_test_image_uri     = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-fast-data:5b013da8-358b-7d26-e793-7f3140b03f71"
  push_report_image_uri   = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-push-report:ce08702c-5697-a683-a15a-edd1fe1d92dd"
}

