Run  tests:
0. start local stack 
1. install tflocal, terraform 1.1.7
2. run `terraform init`
3. run `terraform plan -input=false`
4. run `tflocal apply -target=aws_s3_object.great_expectations_yml -target=aws_s3_object.test_configs -target=aws_s3_object.pipeline_config -target=aws_s3_object.pks_config -target=aws_s3_object.mapping_config -target=aws_s3_object.expectations_store -target=aws_s3_object.test_config_manifest -auto-approve` from root directory 
check that S3 bucket has been created in local stack with command `aws --endpoint-url=http://localhost:4566 s3 ls s3://`
build container with lambda from data_test dicrectory `docker build -t data-test  .`
build container with integration tests from directory `./tests/integration_tests` with command `docker build -t integration-tests .`
run test `docker run --env QA_BUCKET=BUCKET_NAME integration-tests` where BUCKET_NAME is name of bucket from terraform output 