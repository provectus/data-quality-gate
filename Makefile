run-localstack:
	docker run --rm -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1

deploy-qa-infra:
	cd ./examples/localstack && \
	terraform init && \
	terraform apply -target=module.integration_tests_data_qa.aws_s3_object.great_expectations_yml -target=module.integration_tests_data_qa.aws_s3_object.test_configs -target=module.integration_tests_data_qa.aws_s3_object.pipeline_config -target=module.integration_tests_data_qa.aws_s3_object.pks_config -target=module.integration_tests_data_qa.aws_s3_object.mapping_config -target=module.integration_tests_data_qa.aws_s3_object.expectations_store -target=module.integration_tests_data_qa.aws_s3_object.test_config_manifest -auto-approve

build-data-test-img:
	cd ./functions/data_test && \
	docker build -t data-test:latest .

integration_tests_dir := ./tests/integration_tests/test_data_tests

build-data-test-tests-img: build-data-test-img
	cd $(integration_tests_dir) && \
	docker build -t test_data_tests .

host := host.docker.internal
qa_bucket = integration-test-bucket

run-integration-tests: build-data-test-img build-data-test-tests-img
	cd $(integration_tests_dir)
	docker run --env QA_BUCKET=$(qa_bucket) --env S3_HOST=$(host) test_data_tests
