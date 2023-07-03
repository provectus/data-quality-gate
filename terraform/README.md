## DataQA terraform module

![Preview Image](https://raw.githubusercontent.com/provectus/data-quality-gate/main/docs/inframap.png)

### Pre-requirements

As part of this solution, it is expected to have the necessary existing infrastructure
- At least 1 Vpc
- At least 1 private subnet in vpc
- At least 1 public subnet in vpc(if you want to see DataQA reports in the Web)
- At least 5 vpc endpoints
  - `com.amazonaws.AWS-REGION.dynamodb`
  - `com.amazonaws.AWS-REGION.s3`
  - `com.amazonaws.AWS-REGION.sns`
  - `com.amazonaws.AWS-REGION.monitoring`
  - `com.amazonaws.AWS-REGION.secretsmanager`
- At least 1 AWS S3 bucket with data that you want to test
- At least 1 AWS ECR repository

### List of submodules

- [Alerting](https://github.com/provectus/data-quality-gate/tree/main/terraform/modules/alerting) - provides basic functionality for AWS CloudWatch metrics alerts and forwards them to the Slack messenger. Also used as message bus for `data_report` lambda
- [Athena connector](https://github.com/provectus/data-quality-gate/tree/main/terraform/modules/athena-connector) - builds AWS Athena data catalog and AWS Lambda to allow query internal DynamoDB data table
- [AWS S3 configs](https://github.com/provectus/data-quality-gate/tree/main/terraform/modules/s3-configs) - creates internal AWS S3 bucket for data quality processing. Additionally pushing Allure and GreatExpectations configs to this bucket
- [AWS S3 Gateway](https://github.com/provectus/data-quality-gate/tree/main/terraform/modules/s3-gateway) - creates AWS EC2 instance that serves HTTP requests to see static reports in the web.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.64.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.64.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_athena_connector"></a> [athena\_connector](#module\_athena\_connector) | ./modules/athena-connector | n/a |
| <a name="module_basic_slack_alerting"></a> [basic\_slack\_alerting](#module\_basic\_slack\_alerting) | ./modules/alerting | n/a |
| <a name="module_data_reports_alerting"></a> [data\_reports\_alerting](#module\_data\_reports\_alerting) | ./modules/alerting | n/a |
| <a name="module_lambda_allure_report"></a> [lambda\_allure\_report](#module\_lambda\_allure\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_data_test"></a> [lambda\_data\_test](#module\_lambda\_data\_test) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_push_report"></a> [lambda\_push\_report](#module\_lambda\_push\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_reports_gateway"></a> [reports\_gateway](#module\_reports\_gateway) | ./modules/s3-gateway | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ./modules/s3-configs | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.data_qa_report_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.data_qa_report_table_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.data_qa_report_table_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.data_qa_report_table_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.state_machine_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_dynamodb_table.data_qa_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.basic_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cloud_watch_logs_delivery_full_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_invoke_scoped_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.xray_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.step_functions_fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.data_test_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.push_report_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.push_report_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sfn_state_machine.fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allure_report_extra_vars"></a> [allure\_report\_extra\_vars](#input\_allure\_report\_extra\_vars) | Extra environment variables for allure report lambda | `map(string)` | `{}` | no |
| <a name="input_allure_report_image_uri"></a> [allure\_report\_image\_uri](#input\_allure\_report\_image\_uri) | Allure report image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_basic_alert_notification_settings"></a> [basic\_alert\_notification\_settings](#input\_basic\_alert\_notification\_settings) | Base alert notifications settings. If empty - basic alerts will be disabled | <pre>object({<br>    channel     = string<br>    webhook_url = string<br>  })</pre> | `null` | no |
| <a name="input_data_reports_notification_settings"></a> [data\_reports\_notification\_settings](#input\_data\_reports\_notification\_settings) | Data reports notifications settings. If empty - notifications will be disabled | <pre>object({<br>    channel     = string<br>    webhook_url = string<br>  })</pre> | `null` | no |
| <a name="input_data_test_extra_vars"></a> [data\_test\_extra\_vars](#input\_data\_test\_extra\_vars) | Extra environment variables for data test lambda | `map(string)` | `{}` | no |
| <a name="input_data_test_image_uri"></a> [data\_test\_image\_uri](#input\_data\_test\_image\_uri) | Data test image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_data_test_storage_bucket_name"></a> [data\_test\_storage\_bucket\_name](#input\_data\_test\_storage\_bucket\_name) | Bucket name which will be used to store data tests and settings for it's execution | `string` | n/a | yes |
| <a name="input_dynamodb_autoscaling_defaults"></a> [dynamodb\_autoscaling\_defaults](#input\_dynamodb\_autoscaling\_defaults) | A map of default autoscaling settings | `map(string)` | <pre>{<br>  "scale_in_cooldown": 50,<br>  "scale_out_cooldown": 40,<br>  "target_value": 45<br>}</pre> | no |
| <a name="input_dynamodb_autoscaling_read"></a> [dynamodb\_autoscaling\_read](#input\_dynamodb\_autoscaling\_read) | A map of read autoscaling settings. `max_capacity` is the only required key. | `map(string)` | <pre>{<br>  "max_capacity": 200<br>}</pre> | no |
| <a name="input_dynamodb_autoscaling_write"></a> [dynamodb\_autoscaling\_write](#input\_dynamodb\_autoscaling\_write) | A map of write autoscaling settings. `max_capacity` is the only required key. | `map(string)` | <pre>{<br>  "max_capacity": 10<br>}</pre> | no |
| <a name="input_dynamodb_hash_key"></a> [dynamodb\_hash\_key](#input\_dynamodb\_hash\_key) | The attribute to use as the hash (partition) key. Must also be defined as an attribute | `string` | `"file"` | no |
| <a name="input_dynamodb_read_capacity"></a> [dynamodb\_read\_capacity](#input\_dynamodb\_read\_capacity) | Dynamodb report table read capacity | `number` | `20` | no |
| <a name="input_dynamodb_stream_enabled"></a> [dynamodb\_stream\_enabled](#input\_dynamodb\_stream\_enabled) | Dynamodb report table stream enabled | `bool` | `false` | no |
| <a name="input_dynamodb_table_attributes"></a> [dynamodb\_table\_attributes](#input\_dynamodb\_table\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list(map(string))` | <pre>[<br>  {<br>    "name": "file",<br>    "type": "S"<br>  }<br>]</pre> | no |
| <a name="input_dynamodb_write_capacity"></a> [dynamodb\_write\_capacity](#input\_dynamodb\_write\_capacity) | Dynamodb report table write capacity | `number` | `2` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used to build fully qualified tags and resource's names | `string` | n/a | yes |
| <a name="input_expectations_store"></a> [expectations\_store](#input\_expectations\_store) | Path to the expectations\_store directory, relative to the root TF | `string` | `"../../../expectations_store"` | no |
| <a name="input_great_expectation_path"></a> [great\_expectation\_path](#input\_great\_expectation\_path) | Path to the great expectations yaml | `string` | `"../../../templates/great_expectations.yml"` | no |
| <a name="input_lambda_allure_report_memory"></a> [lambda\_allure\_report\_memory](#input\_lambda\_allure\_report\_memory) | Amount of memory allocated to the lambda function lambda\_allure\_report | `number` | `1024` | no |
| <a name="input_lambda_data_test_memory"></a> [lambda\_data\_test\_memory](#input\_lambda\_data\_test\_memory) | Amount of memory allocated to the lambda function lambda\_data\_test | `number` | `5048` | no |
| <a name="input_lambda_private_subnet_ids"></a> [lambda\_private\_subnet\_ids](#input\_lambda\_private\_subnet\_ids) | List of private subnets assigned to lambda | `list(string)` | n/a | yes |
| <a name="input_lambda_push_jira_url"></a> [lambda\_push\_jira\_url](#input\_lambda\_push\_jira\_url) | Lambda function push report env variable JIRA\_URL | `string` | `null` | no |
| <a name="input_lambda_push_report_memory"></a> [lambda\_push\_report\_memory](#input\_lambda\_push\_report\_memory) | Amount of memory allocated to the lambda function lambda\_push\_report | `number` | `1024` | no |
| <a name="input_lambda_push_secret_name"></a> [lambda\_push\_secret\_name](#input\_lambda\_push\_secret\_name) | Lambda function push report env variable JIRA\_URL | `string` | `null` | no |
| <a name="input_lambda_security_group_ids"></a> [lambda\_security\_group\_ids](#input\_lambda\_security\_group\_ids) | List of security group assigned to lambda | `list(string)` | n/a | yes |
| <a name="input_manifest_path"></a> [manifest\_path](#input\_manifest\_path) | Path to the manifests | `string` | `"../../../configs/manifest.json"` | no |
| <a name="input_mapping_path"></a> [mapping\_path](#input\_mapping\_path) | Path to the mapping description path, relative to the root TF | `string` | `"../../../configs/mapping.json"` | no |
| <a name="input_pipeline_config_path"></a> [pipeline\_config\_path](#input\_pipeline\_config\_path) | Path to the pipeline description path, relative to the root TF | `string` | `"../../../configs/pipeline.json"` | no |
| <a name="input_pks_path"></a> [pks\_path](#input\_pks\_path) | Path to the primary keys description path, relative to the root TF | `string` | `"../../../configs/pks.json"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used to build fully qualified tags and resource's names | `string` | `"demo"` | no |
| <a name="input_push_report_extra_vars"></a> [push\_report\_extra\_vars](#input\_push\_report\_extra\_vars) | Extra environment variables for push report lambda | `map(string)` | `{}` | no |
| <a name="input_push_report_image_uri"></a> [push\_report\_image\_uri](#input\_push\_report\_image\_uri) | Push report image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_redshift_db_name"></a> [redshift\_db\_name](#input\_redshift\_db\_name) | Database name for source redshift cluster | `string` | `null` | no |
| <a name="input_redshift_secret"></a> [redshift\_secret](#input\_redshift\_secret) | Secret name from AWS SecretsManager for Redshift cluster | `string` | `null` | no |
| <a name="input_reports_subnet_id"></a> [reports\_subnet\_id](#input\_reports\_subnet\_id) | Subnet id where gateway instance will be placed | `string` | n/a | yes |
| <a name="input_reports_vpc_id"></a> [reports\_vpc\_id](#input\_reports\_vpc\_id) | Vpc Id where gateway instance will be placed | `string` | n/a | yes |
| <a name="input_reports_whitelist_ips"></a> [reports\_whitelist\_ips](#input\_reports\_whitelist\_ips) | List of allowed IPs to see reports | `list(string)` | n/a | yes |
| <a name="input_s3_source_data_bucket"></a> [s3\_source\_data\_bucket](#input\_s3\_source\_data\_bucket) | Bucket name, with the data on which test will be executed | `string` | n/a | yes |
| <a name="input_sort_keys_path"></a> [sort\_keys\_path](#input\_sort\_keys\_path) | Path to the sort keys description path, relative to the root TF | `string` | `"../../../configs/sort_keys.json"` | no |
| <a name="input_test_coverage_path"></a> [test\_coverage\_path](#input\_test\_coverage\_path) | Path to the tests description path, relative to the root TF | `string` | `"../../../configs/test_coverage.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | DataQA bucket with settings and generated tests |
| <a name="output_lambda_allure_arn"></a> [lambda\_allure\_arn](#output\_lambda\_allure\_arn) | Allure reports generation lambda arn |
| <a name="output_lambda_data_test_arn"></a> [lambda\_data\_test\_arn](#output\_lambda\_data\_test\_arn) | Data test generation/running lambda arn |
| <a name="output_lambda_report_push_arn"></a> [lambda\_report\_push\_arn](#output\_lambda\_report\_push\_arn) | Report push to dynamodb lambda arn |
| <a name="output_step_function_arn"></a> [step\_function\_arn](#output\_step\_function\_arn) | DataQA step function arn |
<!-- END_TF_DOCS -->
