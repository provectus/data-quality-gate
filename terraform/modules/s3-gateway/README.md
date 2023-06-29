Nginx AWS S3 gateway
========================

The Terraform module in this folder is responsible for creating an Nginx AWS S3 gateway that allows serving static reports from AWS S3 over HTTP and applies IP restrictions. 

Underneath, it creates an AWS EC2 instance in a public subnet and installs Nginx with the s3-gateway module. IP restrictions are implemented as rules for security group ingress and set by the `whitelist_ips` variable.
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
| [aws_iam_instance_profile.web_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.push_report_dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.s3_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.connectable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name to serve by gateway(read-only) | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Env tag used to tag resources | `string` | n/a | yes |
| <a name="input_instance_sg_ids"></a> [instance\_sg\_ids](#input\_instance\_sg\_ids) | Extra list of security groups for instance | `list(string)` | `[]` | no |
| <a name="input_instance_subnet_id"></a> [instance\_subnet\_id](#input\_instance\_subnet\_id) | Instance subnet id | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for s3 gateway | `string` | `"t2.micro"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VpcId for s3 gateway | `string` | n/a | yes |
| <a name="input_whitelist_ips"></a> [whitelist\_ips](#input\_whitelist\_ips) | Allowed IPs to ssh/http to host | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_gateway_address"></a> [s3\_gateway\_address](#output\_s3\_gateway\_address) | DNS http address of s3 gateway |
<!-- END_TF_DOCS -->
