
(!) All paths are shown from the project's root

Run  tests:
1. Setup local env for tests from directory `./examples/localstack`
2. build images from docker compose `DOCKER_BUILDKIT=0 docker-compose build`. You have to disable DOCKER_BUILDKIT because docker is not supported build images in order  [issue](https://github.com/docker/compose/issues/6332)
3. Run tests: `QA_BUCKET=integration-test-bucket docker-compose run tests` where BUCKET_NAME is value of `data_test_storage_bucket_name` from `./examples/localstack/main.tf`