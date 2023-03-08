provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Terraform = true
    }
  }
}

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "dqg-settings"
  environment                   = "demo"

  allure_report_image_uri = ""
  data_test_image_uri     = ""
  push_report_image_uri   = ""
}

