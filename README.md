# Data Quality Gate 

## Description
Terrafrom module which setup Data-QA solution(bucket,Stepfunctions Pipeline with AWS Lambda, Metadata Storage. Data-QA Reports) in your infrastructure in 'one-click'. AWS Based. Built on top of Great_expectations and Pandas_profiling

## Usage
Could be used as standard Terraform module, the examples of deployments under `deployment-example` directory.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | 2.18.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.2.2 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.3.1 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.24.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cognito_user_pool"></a> [cognito\_user\_pool](#module\_cognito\_user\_pool) | lgallard/cognito-user-pool/aws | n/a |
| <a name="module_docker_image_allure_report"></a> [docker\_image\_allure\_report](#module\_docker\_image\_allure\_report) | terraform-aws-modules/lambda/aws//modules/docker-build | 3.3.1 |
| <a name="module_docker_image_fast_data"></a> [docker\_image\_fast\_data](#module\_docker\_image\_fast\_data) | terraform-aws-modules/lambda/aws//modules/docker-build | 3.3.1 |
| <a name="module_docker_image_push_report"></a> [docker\_image\_push\_report](#module\_docker\_image\_push\_report) | terraform-aws-modules/lambda/aws//modules/docker-build | 3.3.1 |
| <a name="module_lambda_function_allure_report"></a> [lambda\_function\_allure\_report](#module\_lambda\_function\_allure\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_function_fast_data"></a> [lambda\_function\_fast\_data](#module\_lambda\_function\_fast\_data) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_lambda_function_push_report"></a> [lambda\_function\_push\_report](#module\_lambda\_function\_push\_report) | terraform-aws-modules/lambda/aws | 3.3.1 |
| <a name="module_notify_slack"></a> [notify\_slack](#module\_notify\_slack) | terraform-aws-modules/notify-slack/aws | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.data_qa_report_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.data_qa_report_table_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.data_qa_report_table_read_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.data_qa_report_table_write_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudfront_distribution.s3_distribution_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.s3_distribution_oauth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.data_qa_oai](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudfront_origin_access_identity.never_be_reached](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_cloudwatch_event_rule.guardduty_dataqa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.state-machine-log-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.lambda_allure_report_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_fast_data_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_push_report_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cognito_user_pool_client.user_pool_client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_dynamodb_table.data_qa_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.CloudWatchLogsDeliveryFullAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.LambdaInvokeScopedAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.XRayAccessPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.airflow_start_step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.allow_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.allow_s3_bucket_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.athena_dynamodb_connection_basic_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.fast_data_qa_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.fast_data_qa_basic_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.step_functions_fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.allure_report_s3_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fast_data_qa_athena](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fast_data_qa_basic_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fast_data_s3_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.push_report_dynamo_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.push_report_s3_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.delete_old_reports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.cloudfront_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block_fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.fast-data-qa-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.expectations_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.great_expectations_yml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_config_manifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_configs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_serverlessapplicationrepository_cloudformation_stack.edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/serverlessapplicationrepository_cloudformation_stack) | resource |
| [aws_sfn_state_machine.fast_data_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sns_topic.data_qa_alerts_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_ssm_parameter.data_qa_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.data_qa_datasource_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.data_qa_datasource_folder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.data_qa_dynamo_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.data_qa_qa_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_waf_ipset.ipset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_ipset) | resource |
| [aws_waf_rule.wafrule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_rule) | resource |
| [aws_waf_web_acl.waf_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_web_acl) | resource |
| [random_uuid.allure_report](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.fast_data](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.push_report](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_iam_policy_document.s3_policy_for_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.slack_qa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.great_expectations_yml](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.test_config_manifest](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_allowed_subnets"></a> [cloudfront\_allowed\_subnets](#input\_cloudfront\_allowed\_subnets) | list of allowed subnets, suitable if you wan't use Cognito and allow users to get reports from specific IP address spaces | `list(string)` | `null` | no |
| <a name="input_cloudfront_location_restrictions"></a> [cloudfront\_location\_restrictions](#input\_cloudfront\_location\_restrictions) | List of regions allowed for CloudFront distribution | `list` | <pre>[<br>  "US",<br>  "CA",<br>  "GB",<br>  "DE",<br>  "TR"<br>]</pre> | no |
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | If you already has Cognito user pool which will be used for authentication, you could provide Cognito user pool id here. If it not provided, new Cognito user pool will be created | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Additional AWS Resource prefix for all resource name, e.g. project-environment | `string` | `"data-qa-dev"` | no |
| <a name="input_expectations_store"></a> [expectations\_store](#input\_expectations\_store) | Path to the expectations\_store directory, relative to the root TF | `string` | `"../expectations_store"` | no |
| <a name="input_project"></a> [project](#input\_project) | Name of your project, will be used as a prefix for AWS resources names | `string` | `"demo"` | no |
| <a name="input_s3_source_data_bucket"></a> [s3\_source\_data\_bucket](#input\_s3\_source\_data\_bucket) | Bucket name, with the data on which test will be executed | `string` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | The Slack webhook url, which will be used to send notification if some errors will be found it datasets | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of AWS Resource TAG's which will be added to each resource | `map(string)` | `null` | no |
| <a name="input_test_coverage_path"></a> [test\_coverage\_path](#input\_test\_coverage\_path) | Path to the tests description path, relative to the root TF | `string` | `"../configs/test_coverage.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allure_report_role_arn"></a> [allure\_report\_role\_arn](#output\_allure\_report\_role\_arn) | n/a |
| <a name="output_cloudfront_domain"></a> [cloudfront\_domain](#output\_cloudfront\_domain) | n/a |
| <a name="output_fast_data_role_arn"></a> [fast\_data\_role\_arn](#output\_fast\_data\_role\_arn) | n/a |
| <a name="output_push_report_role_arn"></a> [push\_report\_role\_arn](#output\_push\_report\_role\_arn) | n/a |
| <a name="output_qa_step_functions_arn"></a> [qa\_step\_functions\_arn](#output\_qa\_step\_functions\_arn) | n/a |
<!-- END_TF_DOCS -->
