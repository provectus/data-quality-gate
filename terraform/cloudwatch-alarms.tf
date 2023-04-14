resource "aws_cloudwatch_metric_alarm" "lambda_allure_report_error" {
  actions_enabled           = "true"
  alarm_name                = "${local.resource_name_prefix} ${module.lambda_function_allure_report.lambda_function_name} lambda function has execution errors"
  alarm_description         = "${module.lambda_function_allure_report.lambda_function_name} lambda function allure_report execution completed with errors"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  comparison_operator       = "GreaterThanThreshold"
  period                    = "900"
  threshold                 = "0"
  evaluation_periods        = "1"
  statistic                 = "SampleCount"
  treat_missing_data        = "ignore"
  alarm_actions             = [local.sns_topic_notifications_arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    FunctionName = module.lambda_function_allure_report.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_data_test_error" {
  actions_enabled           = "true"
  alarm_name                = "${local.resource_name_prefix} ${module.lambda_function_data_test.lambda_function_name} lambda function has execution errors"
  alarm_description         = "${module.lambda_function_data_test.lambda_function_name} lambda fast_data got errors"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  comparison_operator       = "GreaterThanThreshold"
  period                    = "900"
  threshold                 = "0"
  evaluation_periods        = "1"
  statistic                 = "SampleCount"
  treat_missing_data        = "ignore"
  alarm_actions             = [local.sns_topic_notifications_arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    FunctionName = module.lambda_function_data_test.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_push_report_error" {
  actions_enabled           = "true"
  alarm_name                = "${local.resource_name_prefix} ${module.lambda_function_push_report.lambda_function_name} lambda function has execution errors"
  alarm_description         = "${module.lambda_function_push_report.lambda_function_name} lambda push report conpleted with error"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  comparison_operator       = "GreaterThanThreshold"
  period                    = "900"
  threshold                 = "0"
  evaluation_periods        = "1"
  statistic                 = "SampleCount"
  treat_missing_data        = "ignore"
  alarm_actions             = [local.sns_topic_notifications_arn]
  ok_actions                = []
  insufficient_data_actions = []

  dimensions = {
    FunctionName = module.lambda_function_push_report.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "bugs" {
  actions_enabled   = "true"
  alarm_name        = "DQ data bug found"
  alarm_description = "DQG found a bug."

  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "ignore"

  metric_name = "suite_failed_count"
  namespace   = "Data-QA"

  threshold          = 0
  period             = 1
  evaluation_periods = 1

  alarm_actions             = ["arn:aws:sns:eu-west-2:024975173233:test-bugs-topic"]
  insufficient_data_actions = []
}