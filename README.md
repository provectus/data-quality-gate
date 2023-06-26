# Data Quality Gate 

## Description
Terrafrom module which setup Data-QA solution(bucket,Stepfunctions Pipeline with AWS Lambda, Metadata Storage. Data-QA Reports) in your infrastructure in 'one-click'. AWS Based. Built on top of Great_expectations, Pandas_profiling, Allure

### Data Test
Main engine based on GX to profile, generate suites and run tests

### Allure Report
Mapping from GX format to Allure Test Report tool

### Report Push
Metadata and metrics aggregation

## Solution Architecture
![Preview Image](https://raw.githubusercontent.com/provectus/data-quality-gate/main/architecture.PNG)

## Usage
Could be used as standard Terraform module, the examples of deployments under `examples` directory.

1. Add to terraform DataQA module as in examples
2. Add to terraform state machine `DataTests` step
```terraform
resource "aws_sfn_state_machine" "data_state_machine" {
  definition = jsonencode(
    {
      StartAt = "GetData"
      States  = {
        GetData = {
          Next       = "DataTests"
          Resource   = aws_lambda_function.some_get_data.function_name
          ResultPath = "$.file"
          Type       = "Task"
        }
        DataTests = {
          Type       = "Task"
          Resource   = "arn:aws:states:::states:startExecution.sync:2",
          End        = true
          Parameters = {
            StateMachineArn = module.data-qa.qa_step_functions_arn
            Input = {
              files = [
                {
                  engine          = "s3"
                  source_root     = var.data_lake_bucket
                  run_name        = "raw_data"
                  "source_data.$" = "$.file"
                }
              ]
            }
          }
        }
      }
    }
  )
  name     = "Data-state-machine"
  role_arn = aws_iam_role.state_machine.arn // role with perms on lambda:InvokeFunction
  type     = "STANDARD"

  logging_configuration {
    include_execution_data = false
    level                  = "OFF"
  }

  tracing_configuration {
    enabled = false
  }
}
```
3. Create AWS Serverless application* - [AthenaDynamoDBConnector](https://us-west-2.console.aws.amazon.com/lambda/home?region=us-west-2#/create/app?applicationId=arn:aws:serverlessrepo:us-east-1:292517598671:applications/AthenaDynamoDBConnector) with parameters:
  - SpillBucket - name of bucket created by terraform module 
  - AthenaCatalogName - The name you will give to this catalog in Athena. It will also be used as the function name.

*Cannot be created automatically by terraform because [terraform-provider-aws/issues/16485](https://github.com/hashicorp/terraform-provider-aws/issues/16485)

4. Create AWS Athena Data Source:
- Data source type -> Amazon DynamoDB
- Connection details -> lambda function -> name of `AthenaCatalogName` from pt.3 
