HOST := host.docker.internal
PORT := 4566
QA_BUCKET := dqg-settings-local
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
	docker build -t "$(test)_integration_tests" .

run-data-test-local: build-lambda-img
	docker_id=$$(docker run -d -p 9000:8080 --env BUCKET=$(QA_BUCKET) \
	--env S3_HOST=$(HOST) --env S3_PORT=$(PORT) --env ENVIRONMENT=local --env REPORTS_WEB=test \
	--env AWS_ACCESS_KEY_ID=test --env AWS_SECRET_ACCESS_KEY=test --env AWS_DEFAULT_REGION=us-east-1 $(test))

run-integration-tests:
	S3_HOST=$(HOST) docker-compose up --abort-on-container-exit --build


build-unit-tests-img:
	cd ./functions/$(test) && \
	docker build --target=unit-tests \
	-t $(test)_unit_tests .

run-unit-tests: build-unit-tests-img
	docker run $(test)_unit_tests
