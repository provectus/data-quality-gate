resource "aws_cloudwatch_log_group" "state-machine-log-group" {
  name              = "/aws/${local.resource_name_prefix}/states/fast-data-qa-logs"
  retention_in_days = 0
}

resource "aws_sfn_state_machine" "fast_data_qa" {
  name     = "${local.resource_name_prefix}-fast-data-qa"
  role_arn = aws_iam_role.step_functions_fast_data_qa.arn

  definition = <<DEFINITION
{
  "Comment": "This is your state machine",
  "StartAt": "Process Tests",
  "States": {
    "Process Tests": {
      "Type": "Map",
      "Iterator": {
        "StartAt": "Data test",
        "States": {
          "Data test": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName": "${module.lambda_function_data_test.lambda_function_qualified_arn}"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException"
                ],
                "IntervalSeconds": 2,
                "MaxAttempts": 6,
                "BackoffRate": 2
              }
            ],
            "Next": "Allure report",
            "ResultPath": "$.report",
            "Catch": [
              {
                "ErrorEquals": [
                  "States.ALL"
                ],
                "Next": "Catch",
                "ResultPath": "$.error"
              }
            ]
          },
          "Catch": {
            "Type": "Pass",
            "End": true,
            "Result": {}
          },
          "Allure report": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName": "${module.lambda_function_allure_report.lambda_function_qualified_arn}"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException"
                ],
                "IntervalSeconds": 2,
                "MaxAttempts": 6,
                "BackoffRate": 2
              }
            ],
            "Next": "Push report",
            "ResultPath": "$.links",
            "Catch": [
              {
                "ErrorEquals": [
                  "States.ALL"
                ],
                "Next": "Catch",
                "ResultPath": "$.error"
              }
            ]
          },
          "Push report": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName": "${module.lambda_function_push_report.lambda_function_qualified_arn}"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException"
                ],
                "IntervalSeconds": 2,
                "MaxAttempts": 6,
                "BackoffRate": 2
              }
            ],
            "ResultPath": "$.dashboard",
            "End": true,
            "Catch": [
              {
                "ErrorEquals": [
                  "States.ALL"
                ],
                "Next": "Catch",
                "ResultPath": "$.error"
              }
            ]
          }
        }
      },
      "ItemsPath": "$.files",
      "Next": "Success"
    },
    "Success": {
      "Type": "Succeed"
    }
  }
}
DEFINITION

  logging_configuration {
    include_execution_data = true
    level                  = "ALL"
    log_destination        = "${aws_cloudwatch_log_group.state-machine-log-group.arn}:*"
  }

  tracing_configuration {
    enabled = false
  }
}

resource "aws_iam_role" "step_functions_fast_data_qa" {
  name = "${local.resource_name_prefix}-step-functions-fast-data-qa-role"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "states.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns = [
    aws_iam_policy.CloudWatchLogsDeliveryFullAccessPolicy.arn,
    aws_iam_policy.LambdaInvokeScopedAccessPolicy.arn,
    aws_iam_policy.XRayAccessPolicy.arn
  ]
  max_session_duration = 3600
  path                 = "/${var.environment}/"
}

resource "aws_iam_policy" "CloudWatchLogsDeliveryFullAccessPolicy" {
  description = "Allows AWS Step Functions to write execution logs to CloudWatch Logs on your behalf"
  path        = "/${var.environment}/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:DescribeLogGroups",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "LambdaInvokeScopedAccessPolicy" {
  description = "Allow AWS Step Functions to invoke Lambda functions on your behalf"
  path        = "/${var.environment}/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "lambda:InvokeFunction",
          ]
          Effect = "Allow"
          Resource = [
            "${module.lambda_function_allure_report.lambda_function_arn}*",
            "${module.lambda_function_data_test.lambda_function_arn}*",
            "${module.lambda_function_push_report.lambda_function_arn}*"
          ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "XRayAccessPolicy" {
  description = "Allow AWS Step Functions to call X-Ray daemon on your behalf"
  path        = "/${var.environment}/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords",
            "xray:GetSamplingRules",
            "xray:GetSamplingTargets",
          ]
          Effect = "Allow"
          Resource = [
            "*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
