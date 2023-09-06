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

## Pricing

This solution is completely free because it is open source. However, if you want to integrate it into a live/production environment, there will be associated costs due to its cloud-based nature. These costs can be divided into two parts: the required infrastructure (which you may already have in place, such as VPCs and subnets) and the AWS services necessary for data quality implementation.

*Note: All the information provided below has been calculated using the maximum score strategy.*
#### Pricing for required infrastructure

| AWS Service  | Approximate monthly cost| Description |
| ------------- | -------------  | ------------- |
| AWS S3 and DynamoDB endpoints  | - | There is no extra charge for gateway-type endpoints. You only pay for the usage of S3 and DynamoDB itself. |
| AWS Interface VPC endpoints(secrets manager, monitoring, sns) | 3 endpoints * (30 days * 24 hours * 0.01 rate) = 21.6 USD  | Interface endpoints charged by hour. 1 hour = $0.01  |
| AWS ECRs (allure, data_test, reports, notifications) | 7 versions * (865mb + 432mb + 380mb) => 11.3gb * 0.1 rate per gb month= 1.13 USD | allure image size = 865mb, data_test image size = 432mb, reports image size = 380mb, notifications image size = 160mb. For the purpose of our calculations, let's assume we are storing 7 versions of each image. |
| AWS QuickSight | $7.3 aprx rate per user * 5 = 36.4 USD | Let's assume you have a team consisting of 5 individuals who are interested in the QuickSight data quality dashboard. They frequently check for changes, typically 2-3 times per day. |

<u>Monthly total is $59.13 US$ per month</u>
___

#### Pricing for data quality specific infrastructure
For most of the services used by Data Quality, AWS offers a free-tier supply. Additionally, the costs for these services are typically just a fraction of a cent. To provide further clarity, below you can find a basic cost formula and a few usage examples with cost estimations.

We are going to count:
- number of AWS Lambda runs
- number of AWS StepFunction transitions
- web reports AWS EC2 instance running(720 hrs per month)

| Description  | Formula |
| ------------- | -------------  |
| number of AWS Lambda runs for each | (number of data sources * number of changes * work_days_month) * lambda specific rate(depends on lambda duration and memory used) |
| number of AWS StepFunction transitions  | number of lambda runs * 2 |

##### Small

Let's say we have 1000 data sources and half of them changed every day. Number of runs formula for any lambda is **(1000 data sources  * 0.5 changed * 30 days)**

| AWS Service       | Number of runs | Price  |
| ------------ | -------------- | ------ |
| AWS Lambda AllureReport | 15000          | $8.33  |
| AWS Lambda DataTest     | 15000          | $67.28 |
| AWS Lambda Reports      | 15000          | $2.08  |
| AWS StepFunctions      | 15000          | $0.65 |
| AWS EC2 Reports S3 Gateway      | 720 hrs          | $7.25 |

<u>Monthly total: 85.59 US$</u>

___

##### Medium

Let's say we have 10000 data sources and 70% of them changed every day.
Number of runs formula for any lambda is **(10000 data sources  * 0.7 changes * 30 days)**

| AWS Service       | Number of runs | Price  |
| ------------ | -------------- | ------ |
| AWS Lambda AllureReport | 210k          | $203.33  |
| AWS Lambda DataTest     | 210k          | $1028.57 |
| AWS Lambda Reports      | 210k          | $115.83  |
| AWS StepFunctions      | 210k          | $10.40 |
| AWS EC2 Reports S3 Gateway      | 720 hrs          | $7.25 |

<u>Monthly total: 1 365.38 US$</u>

___

##### Large

Let's say we have 30000 data sources and all of them changed every day.
Number of runs formula for any lambda is **(30000 data sources  * 1 changes * 30 days)**

| AWS Service       | Number of runs | Price  |
| ------------ | -------------- | ------ |
| AWS Lambda AllureReport | 900k          | $893.34  |
| AWS Lambda DataTest     | 900k         | $4430.06 |
| AWS Lambda Reports      | 900k          | $518.33  |
| AWS StepFunctions      | 900k          | $44.90 |
| AWS EC2 Reports S3 Gateway      | 720 hrs          | $7.25 |

<u>Monthly total: 5 893.88 US$</u>
___

**Price per changed data source: 0.006 US$**


## License

Apache 2 Licensed. See [LICENSE](https://github.com/provectus/data-quality-gate/tree/main/LICENSE) for full details.
