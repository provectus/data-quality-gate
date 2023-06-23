<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_function_allure_report"></a> [lambda\_function\_allure\_report](#module\_lambda\_function\_allure\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_function_data_test"></a> [lambda\_function\_data\_test](#module\_lambda\_function\_data\_test) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_function_push_report"></a> [lambda\_function\_push\_report](#module\_lambda\_function\_push\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_slack_notifier"></a> [slack\_notifier](#module\_slack\_notifier) | ./modules/slack-notification | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.data_qa_report_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.data_qa_report_table_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.data_qa_report_table_read_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.data_qa_report_table_write_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudfront_distribution.s3_distribution_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.data_qa_oai](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_origin_access_identity.never_be_reached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudwatch_log_group.state-machine-log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.lambda_allure_report_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_data_test_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_push_report_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_dynamodb_table.data_qa_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.CloudWatchLogsDeliveryFullAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.LambdaInvokeScopedAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.XRayAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.basic_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.data_test_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.step_functions_fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.data_test_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.settings_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.delete_old_reports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.cloudfront_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block_fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.fast-data-qa-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.expectations_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.great_expectations_yml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.mapping_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pipeline_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pks_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.sort_keys_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_config_manifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_configs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_sfn_state_machine.fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sns_topic.notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_wafv2_ip_set.vpn_ipset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.waf_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.s3_policy_for_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.slack_notification_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allure_report_image_uri"></a> [allure\_report\_image\_uri](#input\_allure\_report\_image\_uri) | Allure report image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_cloudfront_allowed_subnets"></a> [cloudfront\_allowed\_subnets](#input\_cloudfront\_allowed\_subnets) | list of allowed subnets allows users to get reports from specific IP address spaces | `list(string)` | `null` | no |
| <a name="input_cloudfront_location_restrictions"></a> [cloudfront\_location\_restrictions](#input\_cloudfront\_location\_restrictions) | List of regions allowed for CloudFront distribution | `list(string)` | <pre>[<br>  "US",<br>  "CA",<br>  "GB",<br>  "DE",<br>  "TR"<br>]</pre> | no |
| <a name="input_create_cloudwatch_notifications_topic"></a> [create\_cloudwatch\_notifications\_topic](#input\_create\_cloudwatch\_notifications\_topic) | Should sns topic for cloudwatch alerts be created | `bool` | `true` | no |
| <a name="input_data_test_image_uri"></a> [data\_test\_image\_uri](#input\_data\_test\_image\_uri) | Data test image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_data_test_storage_bucket_name"></a> [data\_test\_storage\_bucket\_name](#input\_data\_test\_storage\_bucket\_name) | Bucket name which will be used to store data tests and settings for it's execution | `string` | n/a | yes |
| <a name="input_dynamodb_read_capacity"></a> [dynamodb\_read\_capacity](#input\_dynamodb\_read\_capacity) | Dynamodb report table read capacity | `number` | `20` | no |
| <a name="input_dynamodb_report_table_autoscaling_read_capacity_settings"></a> [dynamodb\_report\_table\_autoscaling\_read\_capacity\_settings](#input\_dynamodb\_report\_table\_autoscaling\_read\_capacity\_settings) | Report table autoscaling read capacity | <pre>object({<br>    min = number<br>    max = number<br>  })</pre> | <pre>{<br>  "max": 200,<br>  "min": 50<br>}</pre> | no |
| <a name="input_dynamodb_report_table_autoscaling_write_capacity_settings"></a> [dynamodb\_report\_table\_autoscaling\_write\_capacity\_settings](#input\_dynamodb\_report\_table\_autoscaling\_write\_capacity\_settings) | Report table autoscaling write capacity | <pre>object({<br>    min = number<br>    max = number<br>  })</pre> | <pre>{<br>  "max": 50,<br>  "min": 2<br>}</pre> | no |
| <a name="input_dynamodb_report_table_read_scale_threshold"></a> [dynamodb\_report\_table\_read\_scale\_threshold](#input\_dynamodb\_report\_table\_read\_scale\_threshold) | Dynamodb report table read scale up threshold | `number` | `60` | no |
| <a name="input_dynamodb_report_table_write_scale_threshold"></a> [dynamodb\_report\_table\_write\_scale\_threshold](#input\_dynamodb\_report\_table\_write\_scale\_threshold) | Dynamodb report table write scale up threshold | `number` | `70` | no |
| <a name="input_dynamodb_stream_enabled"></a> [dynamodb\_stream\_enabled](#input\_dynamodb\_stream\_enabled) | Dynamodb report table stream enabled | `bool` | `false` | no |
| <a name="input_dynamodb_table_attributes"></a> [dynamodb\_table\_attributes](#input\_dynamodb\_table\_attributes) | List of nested attribute definitions. Only required for hash\_key and range\_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data | `list(map(string))` | `[]` | no |
| <a name="input_dynamodb_write_capacity"></a> [dynamodb\_write\_capacity](#input\_dynamodb\_write\_capacity) | Dynamodb report table write capacity | `number` | `2` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used to build fully qualified tags and resource's names | `string` | `"data-qa-dev"` | no |
| <a name="input_expectations_store"></a> [expectations\_store](#input\_expectations\_store) | Path to the expectations\_store directory, relative to the root TF | `string` | `"../expectations_store"` | no |
| <a name="input_lambda_allure_report_memory"></a> [lambda\_allure\_report\_memory](#input\_lambda\_allure\_report\_memory) | Amount of memory allocated to the lambda function lambda\_allure\_report | `number` | `1024` | no |
| <a name="input_lambda_data_test_memory"></a> [lambda\_data\_test\_memory](#input\_lambda\_data\_test\_memory) | Amount of memory allocated to the lambda function lambda\_data\_test | `number` | `5048` | no |
| <a name="input_lambda_push_jira_url"></a> [lambda\_push\_jira\_url](#input\_lambda\_push\_jira\_url) | Lambda function push report env variable JIRA\_URL | `string` | `null` | no |
| <a name="input_lambda_push_report_memory"></a> [lambda\_push\_report\_memory](#input\_lambda\_push\_report\_memory) | Amount of memory allocated to the lambda function lambda\_push\_report | `number` | `1024` | no |
| <a name="input_lambda_push_secret_name"></a> [lambda\_push\_secret\_name](#input\_lambda\_push\_secret\_name) | Lambda function push report env variable JIRA\_URL | `string` | `null` | no |
| <a name="input_mapping_path"></a> [mapping\_path](#input\_mapping\_path) | Path to the mapping description path, relative to the root TF | `string` | `"../configs/mapping.json"` | no |
| <a name="input_pipeline_config_path"></a> [pipeline\_config\_path](#input\_pipeline\_config\_path) | Path to the pipeline description path, relative to the root TF | `string` | `"../configs/pipeline.json"` | no |
| <a name="input_pks_path"></a> [pks\_path](#input\_pks\_path) | Path to the primary keys description path, relative to the root TF | `string` | `"../configs/pks.json"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name used to build fully qualified tags and resource's names | `string` | `"demo"` | no |
| <a name="input_push_report_image_uri"></a> [push\_report\_image\_uri](#input\_push\_report\_image\_uri) | Push report image URI(ECR repository) | `string` | n/a | yes |
| <a name="input_redshift_db_name"></a> [redshift\_db\_name](#input\_redshift\_db\_name) | Database name for source redshift cluster | `string` | `null` | no |
| <a name="input_redshift_secret"></a> [redshift\_secret](#input\_redshift\_secret) | Secret name from AWS SecretsManager for Redshift cluster | `string` | `null` | no |
| <a name="input_slack_settings"></a> [slack\_settings](#input\_slack\_settings) | Slack notifications settings. If null - slack notifications will be disabled | <pre>object({<br>    webhook_url = string<br>    channel     = string<br>    username    = string<br>    image_uri   = string<br>    vpc_id      = string<br>  })</pre> | `null` | no |
| <a name="input_sns_cloudwatch_notifications_topic_arn"></a> [sns\_cloudwatch\_notifications\_topic\_arn](#input\_sns\_cloudwatch\_notifications\_topic\_arn) | SNS topic to send cloudwatch events | `string` | `null` | no |
| <a name="input_sort_keys_path"></a> [sort\_keys\_path](#input\_sort\_keys\_path) | Path to the sort keys description path, relative to the root TF | `string` | `"../configs/sort_keys.json"` | no |
| <a name="input_test_coverage_path"></a> [test\_coverage\_path](#input\_test\_coverage\_path) | Path to the tests description path, relative to the root TF | `string` | `"../configs/test_coverage.json"` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group assigned to lambda. If null value, default subnet and vpc will be used | `list(string)` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet ids to place lambda in. If null value, default subnet and vpc will be used | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allure_report_role_arn"></a> [allure\_report\_role\_arn](#output\_allure\_report\_role\_arn) | n/a |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Data quality gate bucket with settings and generated tests |
| <a name="output_data_test_role_arn"></a> [data\_test\_role\_arn](#output\_data\_test\_role\_arn) | n/a |
| <a name="output_lambda_allure_arn"></a> [lambda\_allure\_arn](#output\_lambda\_allure\_arn) | n/a |
| <a name="output_lambda_data_test_arn"></a> [lambda\_data\_test\_arn](#output\_lambda\_data\_test\_arn) | n/a |
| <a name="output_lambda_report_push_arn"></a> [lambda\_report\_push\_arn](#output\_lambda\_report\_push\_arn) | n/a |
| <a name="output_report_push_role_arn"></a> [report\_push\_role\_arn](#output\_report\_push\_role\_arn) | n/a |
| <a name="output_step_function_arn"></a> [step\_function\_arn](#output\_step\_function\_arn) | n/a |
<!-- END_TF_DOCS -->
