0. Install terraform 
1. Navigate to `./tests/integration_tests/infra`
2. Run localstack `docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack:1.3.1`
3. Run `terraform init`
4. Setup S3 environment `terraform apply -auto-approve`
