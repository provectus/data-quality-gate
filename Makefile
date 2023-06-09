HOST := host.docker.internal
PORT := 4566
QA_BUCKET := integration-test-bucket
IMAGE_VERSION := latest

run-localstack:
	docker run --rm -d -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1

deploy-qa-infra:
	cd ./tests/integration_tests/infra && \
	terraform init && \
	terraform apply -auto-approve

build-lambda-img:
	cd ./functions/$(test) && \
	docker build -t $(test):latest .

build-integration-tests-img: build-lambda-img
	cd ./tests/integration_tests/$(test) && \
	docker build --build-arg="IMAGE_NAME=$(test)" \
	--build-arg="VERSION=$(IMAGE_VERSION)" \
	-t "$(test)_integration_tests" .

run-integration-tests: build-integration-tests-img
	cd ./tests/integration_tests/$(test) && \
	docker run --env BUCKET=$(QA_BUCKET) \
	--env S3_HOST=$(HOST) --env S3_PORT=$(PORT) $(test)_integration_tests

build-unit-tests-img: build-lambda-img
	cd ./tests/unit_tests/$(test) && \
	docker build --build-arg="IMAGE_NAME=$(test)" \
	--build-arg="VERSION=$(IMAGE_VERSION)" \
	-t $(test)_unit_tests .

run-unit-tests: build-unit-tests-img
	cd ./tests/unit_tests/$(test) && \
	docker run $(test)_unit_tests
