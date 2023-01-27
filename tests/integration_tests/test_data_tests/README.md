(!) All paths are shown from the project's root

Run  tests:
1. Setup local env for tests from directory `./examples/localstack`
2. build lambda container from directory `./functions/data_test/` directory `docker build -t data-test  .`
3. build container with integration tests from directory `./tests/integration_tests/test_data_tests` with the command `docker build -t integration-tests .`
4. run test `docker run --env QA_BUCKET=integration-test-bucket integration-tests` where BUCKET_NAME is value of `data_test_storage_bucket_name` from `./examples/localstack/main.tf`