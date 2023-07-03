# Data Quality Gate 

## Description
Terrafrom module which setup DataQA solution in your infrastructure in 'one-click'. AWS Based. Built on top of Great_expectations, Pandas_profiling, Allure

### Data Test
Main engine based on GX to profile, generate suites and run tests

### Allure Report
Mapping from GX format to Allure Test Report tool

### Report Push
Metadata and metrics aggregation

## Solution Architecture
![Preview Image](https://raw.githubusercontent.com/provectus/data-quality-gate/main/architecture.PNG)

## Supported Features

- AWS Lambda runtime Python 3.8
- AWS StepFunction pipeline, combining whole DataQA cycle(profiling, test generation, reporting)
- Supports Slack and Jira notifications and reporting
- AWS SNS output message bus, allowing to embed to existing data pipelines
- Web reports delivery through Nginx for companies VPN/IP set
- AWS DynamoDB and Athena integration, allowing to build AWS QuickSight or Grafana dashboards
- Flexible way of config management for underlying technologies such as Allure and GreatExpectation

## Usage

```hcl
module "data_qa" {
  source = "github.com/provectus/data-quality-gate"

  data_test_storage_bucket_name = "my-data-settings-dev"
  s3_source_data_bucket         = "my-data-bucket"
  environment                   = "example"
  project                       = "my-project"

  allure_report_image_uri = "xxxxxxxxxxxx.dkr.ecr.xx-xxxx-x.amazonaws.com/dqg-allure_report:latest"
  data_test_image_uri     = "xxxxxxxxxxxx.dkr.ecr.xx-xxxx-x.amazonaws.com/dqg-data_test:latest"
  push_report_image_uri   = "xxxxxxxxxxxx.dkr.ecr.xx-xxxx-x.amazonaws.com/dqg-push_reportt:latest"

  data_reports_notification_settings = {
    channel     = "DataReportSlackChannelName"
    webhook_url = "https://hooks.slack.com/services/xxxxxxxxxxxxxxx"
  }

  lambda_private_subnet_ids = ["private_subnet_id"]
  lambda_security_group_ids = ["security_group_id"]

  reports_vpc_id        = "some_vpc_id"
  reports_subnet_id     = "subnet_id"
  reports_whitelist_ips = ["0.0.0.0/0"]
}
```

## Examples

Could be used as standard Terraform module, the examples of deployments under `examples` directory.

- [data-qa-basic](https://github.com/provectus/data-quality-gate/tree/main/examples/basic) - Creates DataQA module which builds AWS infrastructure.

## Local Development and Testing

See the [functions](https://github.com/provectus/data-quality-gate/tree/main/functions) for further details.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/provectus/data-quality-gate/tree/main/LICENSE) for full details.
