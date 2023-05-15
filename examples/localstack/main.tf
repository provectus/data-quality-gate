provider "aws" {
  region              = "us-west-2"
  access_key          = "local-access-key"
  secret_key          = "local-secret-key"
  s3_force_path_style = true

  endpoints {
    s3  = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}

module "integration_tests_data_qa" {
  source = "../../terraform"

  data_test_storage_bucket_name = "integration-test-bucket"
  environment                   = "local"

  allure_report_image_uri = ""
  data_test_image_uri     = ""
  push_report_image_uri   = ""

  reports_subnet_id = ""
  reports_vpc_id    = ""

  lambda_private_subnet_ids = []
  lambda_security_group_ids = []

  reports_whitelist_ips = []
}

