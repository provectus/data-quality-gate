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
unit_tests_dir := ./tests/unit_tests

build-data-test-tests-img: build-data-test-img
	cd $(integration_tests_dir) && \
	docker build -t test_data_tests .

build-unit-tests-img: build-data-test-img
	cd $(unit_tests_dir) && \
	docker build -t unit_tests .	

host := host.docker.internal
port:= 4566
qa_bucket = integration-test-bucket

run-integration-tests: build-data-test-img build-data-test-tests-img
	cd $(integration_tests_dir)
	docker run --env BUCKET=$(qa_bucket) --env S3_HOST=$(host) --env S3_PORT=$(port) test_data_tests

prepare-unit-tests:
	cd ./functions/data_test && \
	pip install -r requirements.txt && \
	pip install pytest==7.2.1 && \
	pip install moto==4.1.6

run-unit-tests:
	export ENVIRONMENT='local' && \
	export S3_HOST='localhost' && \
	export S3_PORT='4566' && \
	export BUCKET='test-bucket' && \
	export AWS_DEFAULT_REGION='us-east-1' && \
	export REDSHIFT_DB='titanic' && \
	export REDSHIFT_SECRET='titanic' && \
	cd ./functions/data_test && \
	python -m pytest ../../tests/unit_tests/data_test/ -v

build-data-test-unit-tests-img: build-data-test-img
	cd ./tests/unit_tests/data_test && \
	docker build -t data_test_unit_tests .

run-unit-tests-in-docker: build-data-test-unit-tests-img
	cd ./tests/unit_tests/data_test && \
	docker run --env-file=.env data_test_unit_tests
