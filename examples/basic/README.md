Basic Data QA example
========================

Configuration in this directory shows how to instantiate a Data QA module that consists from various AWS services.

Note, this example does not contain required high-level aws global infrastructure such as vpc and networking. To see module details go to [README](../../terraform/README.md) 

Usage
=====

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS EC2 instance, for example). Run `terraform destroy` when you don't need these resources.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.64.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_qa"></a> [data\_qa](#module\_data\_qa) | ../../terraform | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
