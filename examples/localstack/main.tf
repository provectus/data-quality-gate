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

module "s3_configs" {
  source = "../../terraform/modules/s3-configs"

  #CONFIGs paths here.
}

#Example
#module "s3_bucket" {
#  environment = var.environment
#
#  data_test_storage_bucket_name = relative path
#  test_coverage_path            = relative path
#  pipeline_config_path          = relative path
#  pks_path                      = relative path
#  sort_keys_path                = relative path
#  mapping_path                  = relative path
#  expectations_store            = relative path
#}

