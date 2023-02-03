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
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "test-bucket"
  environment                   = "examples-basic"

  allure_report_image_uri = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-allure-report"
  data_test_image_uri     = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-fast-data"
  push_report_image_uri   = "024975173233.dkr.ecr.eu-west-2.amazonaws.com/demo-test-ip-push-report"
}

