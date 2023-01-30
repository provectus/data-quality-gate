provider "aws" {
  region = "us-west-2"
  access_key                  = "local-access-key"
  secret_key                  = "local-secret-key"
  s3_force_path_style = true

  endpoints {
    s3 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }


  # default_tags {
  #   Terraform = true
  # }
}

module "integration_tests_data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]

  data_test_storage_bucket_name = "integration-test-bucket"
  environment                   = "local"

  allure_report_image_uri = ""
  data_test_image_uri     = ""
  push_report_image_uri   = ""
}

