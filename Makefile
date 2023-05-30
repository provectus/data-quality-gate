HOST := host.docker.internal
PORT := 4566
QA_BUCKET := integration-test-bucket

INTEGRATION_TESTS_DIR := ./tests/integration_tests/test_data_tests
DATA_TEST_UNIT_TESTS_DIR := ./tests/unit_tests/data_test
DATA_TEST_UNIT_TESTS_IMG := data_test_unit_tests
DATA_TEST_INTEGRATION_TESTS_IMG := data_test_integration_tests


run-localstack:
	docker run --rm -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1

deploy-qa-infra:
	cd ./examples/localstack && \
	terraform init && \
	terraform apply -target=module.integration_tests_data_qa.aws_s3_object.great_expectations_yml -target=module.integration_tests_data_qa.aws_s3_object.test_configs -target=module.integration_tests_data_qa.aws_s3_object.pipeline_config -target=module.integration_tests_data_qa.aws_s3_object.pks_config -target=module.integration_tests_data_qa.aws_s3_object.mapping_config -target=module.integration_tests_data_qa.aws_s3_object.expectations_store -target=module.integration_tests_data_qa.aws_s3_object.test_config_manifest -auto-approve

build-data-test-img:
	cd ./functions/data_test && \
	docker build -t data-test:latest .

build-data-test-tests-img: build-data-test-img
	cd $(INTEGRATION_TESTS_DIR) && \
	docker build -t $(DATA_TEST_INTEGRATION_TESTS_IMG) .

run-integration-tests: build-data-test-img build-data-test-tests-img
	cd $(INTEGRATION_TESTS_DIR)
	docker run --env BUCKET=$(QA_BUCKET) --env S3_HOST=$(HOST) --env S3_PORT=$(PORT) $(DATA_TEST_INTEGRATION_TESTS_IMG)

build-data-test-unit-tests-img: build-data-test-img
	cd $(DATA_TEST_UNIT_TESTS_DIR) && \
	docker build -t $(DATA_TEST_UNIT_TESTS_IMG) .

run-unit-tests-in-docker: build-data-test-unit-tests-img
	cd $(DATA_TEST_UNIT_TESTS_DIR) && \
	docker run --env-file=.env $(DATA_TEST_UNIT_TESTS_IMG)
