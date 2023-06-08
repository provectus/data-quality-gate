HOST := host.docker.internal
PORT := 4566
QA_BUCKET := integration-test-bucket

INTEGRATION_TESTS_DIR := ./tests/integration_tests/test_data_tests
DATA_TEST_UNIT_TESTS_DIR := ./tests/unit_tests/data_test
ALLURE_REPORT_UNIT_TESTS_DIR := ./tests/unit_tests/allure_report
REPORT_PUSH_UNIT_TESTS_DIR := ./tests/unit_tests/report_push
DATA_TEST_UNIT_TESTS_IMG := data_test_unit_tests
ALLURE_REPORT_UNIT_TESTS_IMG := allure_report_unit_tests
REPORT_PUSH_UNIT_TESTS_IMG := report_push_unit_tests
DATA_TEST_INTEGRATION_TESTS_IMG := data_test_integration_tests
DATA_TEST_IMAGE_NAME := data_test
DATA_TEST_IMAGE_VERSION := latest
ALLURE_REPORT_IMAGE_NAME := allure_report
ALLURE_REPORT_IMAGE_VERSION := latest
REPORT_PUSH_IMAGE_NAME := report_push
REPORT_PUSH_IMAGE_VERSION := latest

run-localstack:
	docker run --rm -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1

deploy-qa-infra:
	cd ./tests/integration_tests/infra && \
	terraform init && \
	terraform apply -auto-approve

build-data-test-img:
	cd ./functions/data_test && \
	docker build -t $(DATA_TEST_IMAGE_NAME):$(DATA_TEST_IMAGE_VERSION) .

build-allure-report-img:
	cd ./functions/allure_report && \
	docker build -t ${ALLURE_REPORT_IMAGE_NAME}:${ALLURE_REPORT_IMAGE_VERSION} .

build-report-push-img:
	cd ./functions/report_push && \
	docker build -t ${REPORT_PUSH_IMAGE_NAME}:${REPORT_PUSH_IMAGE_VERSION} .

build-data-test-tests-img: build-data-test-img
	cd $(INTEGRATION_TESTS_DIR) && \
	docker build --build-arg="IMAGE_NAME=$(DATA_TEST_IMAGE_NAME)" \
	--build-arg="VERSION=$(DATA_TEST_IMAGE_VERSION)" \
	-t $(DATA_TEST_INTEGRATION_TESTS_IMG) .

run-integration-tests: build-data-test-img build-data-test-tests-img
	cd $(INTEGRATION_TESTS_DIR)
	docker run --env BUCKET=$(QA_BUCKET) \
	--env S3_HOST=$(HOST) --env S3_PORT=$(PORT) $(DATA_TEST_INTEGRATION_TESTS_IMG)

build-data-test-unit-tests-img: build-data-test-img
	cd $(DATA_TEST_UNIT_TESTS_DIR) && \
	docker build --build-arg="IMAGE_NAME=$(DATA_TEST_IMAGE_NAME)" \
	--build-arg="VERSION=$(DATA_TEST_IMAGE_VERSION)" \
	-t $(DATA_TEST_UNIT_TESTS_IMG) .

build-allure-report-unit-tests-img: build-allure-report-img
	cd $(ALLURE_REPORT_UNIT_TESTS_DIR) && \
	docker build --build-arg="IMAGE_NAME=$(ALLURE_REPORT_IMAGE_NAME)" \
	--build-arg="VERSION=$(ALLURE_REPORT_IMAGE_VERSION)" \
	-t $(ALLURE_REPORT_UNIT_TESTS_IMG) .

build-report-push-unit-tests-img: build-report-push-img
	cd $(REPORT_PUSH_UNIT_TESTS_DIR) && \
	docker build --build-arg="IMAGE_NAME=$(REPORT_PUSH_IMAGE_NAME)" \
	--build-arg="VERSION=$(REPORT_PUSH_IMAGE_VERSION)" \
	-t $(REPORT_PUSH_UNIT_TESTS_IMG) .

run-data-test-unit-tests: build-data-test-unit-tests-img
	cd $(DATA_TEST_UNIT_TESTS_DIR) && \
	docker run $(DATA_TEST_UNIT_TESTS_IMG)

run-allure-report-unit-tests: build-allure-report-unit-tests-img
	cd $(ALLURE_REPORT_UNIT_TESTS_DIR) && \
	docker run $(ALLURE_REPORT_UNIT_TESTS_IMG)

run-report-push-unit-tests: build-report-push-unit-tests-img
	cd $(REPORT_PUSH_UNIT_TESTS_DIR) && \
	docker run $(REPORT_PUSH_UNIT_TESTS_IMG)