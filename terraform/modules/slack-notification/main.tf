locals {
  tags = {
    Name = local.lambda_function_name
  }

  lambda_function_name             = "DataQuality-slack-notification"
  aws_cloudwatch_metric_alarm_name = "${local.lambda_function_name}-failed"
}

data "aws_caller_identity" "current" {}