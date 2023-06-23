provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Terraform = true
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "data_qa" {
  source = "../../terraform"

  data_test_storage_bucket_name = "dqg-settings-dev"
  s3_source_data_bucket         = "data-bucket-name"
  environment                   = "demo"
  project                       = "provectus"

  allure_report_image_uri = "..."
  data_test_image_uri     = "..."
  push_report_image_uri   = "..."

  data_reports_notification_settings = {
    channel     = "DataReportSlackChannelName"
    webhook_url = "https://hooks.slack.com/services/........"
  }

  lambda_private_subnet_ids = ["private_subnet_id"]
  lambda_security_group_ids = ["security_group_id"]

  reports_vpc_id        = "some_vpc_id"
  reports_subnet_id     = "subnet_id"
  reports_whitelist_ips = ["0.0.0.0/0"]

  test_coverage_path     = "../../configs/test_coverage.json"
  pipeline_config_path   = "../../configs/pipeline.json"
  pks_path               = "../../configs/pks.json"
  sort_keys_path         = "../../configs/sort_keys.json"
  mapping_path           = "../../configs/mapping.json"
  manifest_path          = "../../configs/manifest.json"
  great_expectation_path = "../../templates/great_expectations.yml"
  expectations_store     = "../../expectations_store"
}
