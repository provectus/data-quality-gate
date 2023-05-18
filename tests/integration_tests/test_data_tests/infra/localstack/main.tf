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
  test_coverage_path            = "../config/test_coverage.json"
  pipeline_config_path          = "../config/pipeline.json"
  pks_path                      = "../config/pks.json"
  sort_keys_path                = "../config/sort_keys.json"
  mapping_path                  = "../config/mapping.json"
}

#Example
module "s3_bucket" {
 environment = var.environment

 data_test_storage_bucket_name = "integration-test-bucket"
 test_coverage_path            = "${path.module}/${var.test_coverage_path}"
 pipeline_config_path          = "${path.module}/${var.pipeline_config_path}"
 pks_path                      = "${path.module}/${var.pks_path}"
 sort_keys_path                = "${path.module}/${var.sort_keys_path}"
 mapping_path                  = "${path.module}/${var.mapping_path}"
 expectations_store            = "${path.module}/${var.expectations_store}/${each.value}"
}

