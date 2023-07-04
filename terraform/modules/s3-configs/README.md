AWS S3 bucket and configs
=======================

The Terraform module in this folder is responsible for creating an AWS S3 bucket that used by DataQA as a basic bucket to store configs and generated tests into it.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.settings_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.delete_old_reports](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.settings_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.settings_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.expectations_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.great_expectations_yml](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.mapping_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pipeline_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pks_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.sort_keys_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_config_manifest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.test_configs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_test_storage_bucket_name"></a> [data\_test\_storage\_bucket\_name](#input\_data\_test\_storage\_bucket\_name) | Bucket name which will be used to store data tests and settings for it's execution | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name used to build fully qualified tags and resource's names | `string` | n/a | yes |
| <a name="input_expectations_store"></a> [expectations\_store](#input\_expectations\_store) | Path to the expectations\_store directory, relative to the root TF | `string` | n/a | yes |
| <a name="input_great_expectation_path"></a> [great\_expectation\_path](#input\_great\_expectation\_path) | Path to the great expectations yaml | `string` | n/a | yes |
| <a name="input_manifest_path"></a> [manifest\_path](#input\_manifest\_path) | Path to the manifests | `string` | n/a | yes |
| <a name="input_mapping_path"></a> [mapping\_path](#input\_mapping\_path) | Path to the mapping description path, relative to the root TF | `string` | n/a | yes |
| <a name="input_pipeline_config_path"></a> [pipeline\_config\_path](#input\_pipeline\_config\_path) | Path to the pipeline description path, relative to the root TF | `string` | n/a | yes |
| <a name="input_pks_path"></a> [pks\_path](#input\_pks\_path) | Path to the primary keys description path, relative to the root TF | `string` | n/a | yes |
| <a name="input_sort_keys_path"></a> [sort\_keys\_path](#input\_sort\_keys\_path) | Path to the sort keys description path, relative to the root TF | `string` | n/a | yes |
| <a name="input_test_coverage_path"></a> [test\_coverage\_path](#input\_test\_coverage\_path) | Path to the tests description path, relative to the root TF | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of s3 configs bucket |
<!-- END_TF_DOCS -->
