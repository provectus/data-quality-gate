provider "aws" {
  region = "us-west-2"

  default_tags {
    Terraform = true
  }
}

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "test-bucket"
  environment                   = "dev"

  allure_report_image_uri = ""
  data_test_image_uri     = ""
  push_report_image_uri   = ""
}

