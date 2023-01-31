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
  statistic                 = "SampleCount" #Average, Maximum, Sum
  treat_missing_data        = "ignore"      #missing
  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_function_allure_report.lambda_function_name
  }
  tags = merge(
    local.tags
  )
}

resource "aws_cloudwatch_metric_alarm" "lambda_fast_data_error" {
  actions_enabled           = "true"
  alarm_name                = "${local.resource_name_prefix} ${module.lambda_function_fast_data.lambda_function_name} lambda function has execution errors"
  alarm_description         = "${module.lambda_function_fast_data.lambda_function_name} lambda fast_data got errors"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  comparison_operator       = "GreaterThanThreshold"
  period                    = "900"
  threshold                 = "0"
  evaluation_periods        = "1"
  statistic                 = "SampleCount" #Average, Maximum, Sum
  treat_missing_data        = "ignore"      #missing
  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_function_fast_data.lambda_function_name
  }
  tags = merge(
    local.tags
  )
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
  statistic                 = "SampleCount" #Average, Maximum, Sum
  treat_missing_data        = "ignore"      #missing
  alarm_actions             = [var.sns_topic_arn]
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_function_push_report.lambda_function_name
  }
  tags = merge(
    local.tags
  )
}
