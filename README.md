# Data Quality Gate 

## Description
Data Quality Gate is a Terraform module that enables data engineers and data QA professionals to effortlessly set up the Provectus DataQA solution within their infrastructure in a single click. It is AWS-based and built on the solid foundation of Great Expectations, YData Profiling (ex. Pandas Profiling), and Allure.

### Data Test
The main engine, based on Great Expectations (GX), is used to profile, generate suites, and run tests.

### Allure Report
The mapping from the GX format into the Allure Test Report tool is executed,

### Report Push
The existing metadata and metrics are aggregated and pushed down the pipeline.

## Solution Architecture
![Preview Image](https://raw.githubusercontent.com/provectus/data-quality-gate/main/architecture.PNG)

## Supported Features

1. AWS Lambda Runtime: Utilizes Python 3.9.
2. AWS Step Functions Pipeline: Incorporates the entire DataQA cycle, including profiling, test generation, and reporting.
3. Notifications and Reporting: Offers support for Slack and Jira notifications and reporting.
4. AWS SNS: Outputs message bus, allowing for seamless integration with existing data pipelines.
5. Web Reports Delivery: Provides report delivery via Nginx for company-specific VPN/IP settings.
6. AWS DynamoDB and Athena Integration: Enables the construction of AWS QuickSight or Grafana dashboards.
7. Configuration Management: Provides a flexible method for managing configurations of underlying technologies like Allure and Great Expectations.

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

The tool can be used as a standard Terraform module, with deployment examples provided in the `examples` directory.

- [Data-QA-Basic](https://github.com/provectus/data-quality-gate/tree/main/examples/basic) - Creates a DataQA module that builds AWS infrastructure.

## Local Development and Testing

See the [functions](https://github.com/provectus/data-quality-gate/tree/main/functions) for further details.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/provectus/data-quality-gate/tree/main/LICENSE) for full details.
