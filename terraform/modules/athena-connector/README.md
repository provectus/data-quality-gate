AWS Athena connector
=======================

The module in this folder creates AWS Athena DataCatalog and AWS Lambda function that serves requests from AWS Athena to AWS DynamoDB.
It uses official AWS DynamoDB [connector](https://docs.aws.amazon.com/athena/latest/ug/connectors-dynamodb.html). 


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.64.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.5.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.athena_connector_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.athena_connector_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.athena_connector_basic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.athena_dynamodb_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_s3_bucket.athena_spill_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.athena_spill_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [null_resource.athena_dynamodb_connector](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.delete_athena_dynamodb_connector](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_catalog_name"></a> [data\_catalog\_name](#input\_data\_catalog\_name) | Name of athena data catalog | `string` | n/a | yes |
| <a name="input_delete_athena_dynamodb_connector"></a> [delete\_athena\_dynamodb\_connector](#input\_delete\_athena\_dynamodb\_connector) | Set to True to delete athena dynamodb connector | `bool` | `false` | no |
| <a name="input_primary_aws_region"></a> [primary\_aws\_region](#input\_primary\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group assigned to lambda. If null value, default subnet and vpc will be used | `list(string)` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet ids to place lambda in. If null value, default subnet and vpc will be used | `list(string)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
