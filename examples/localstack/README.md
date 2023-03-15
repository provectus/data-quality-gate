0. Install terraform 
1. Navigate to `./examples/localstack`
2. Run localstack `docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1`
3. Run `terraform init`
4. Setup S3 environment `terraform apply -target=module.integration_tests_data_qa.aws_s3_object.great_expectations_yml -target=module.integration_tests_data_qa.aws_s3_object.test_configs -target=module.integration_tests_data_qa.aws_s3_object.pipeline_config -target=module.integration_tests_data_qa.aws_s3_object.pks_config -target=module.integration_tests_data_qa.aws_s3_object.mapping_config -target=module.integration_tests_data_qa.aws_s3_object.expectations_store -target=module.integration_tests_data_qa.aws_s3_object.test_config_manifest -auto-approve`