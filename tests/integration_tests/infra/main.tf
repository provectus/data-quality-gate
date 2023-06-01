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
  source                        = "../../../terraform/modules/s3-configs"
  environment                   = "local"
  data_test_storage_bucket_name = "dqg-settings-local"

  test_coverage_path     = "../../../tests/integration_tests/infra/configs/test_coverage.json"
  pipeline_config_path   = "../../../tests/integration_tests/infra/configs/pipeline.json"
  pks_path               = "../../../tests/integration_tests/infra/configs/pks.json"
  sort_keys_path         = "../../../tests/integration_tests/infra/configs/sort_keys.json"
  mapping_path           = "../../../tests/integration_tests/infra/configs/mapping.json"
  manifest_path          = "../../../tests/integration_tests/infra/configs/manifest.json"
  great_expectation_path = "../../../tests/integration_tests/infra/templates/great_expectations.yml"
  expectations_store     = "../../../tests/integration_tests/infra/expectations_store"
}
