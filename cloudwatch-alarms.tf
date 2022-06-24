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
  alarm_actions             = [aws_sns_topic.data_qa_alerts_notifications.arn]
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
  alarm_actions             = [aws_sns_topic.data_qa_alerts_notifications.arn]
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
  alarm_actions             = [aws_sns_topic.data_qa_alerts_notifications.arn]
  ok_actions                = []
  insufficient_data_actions = []
  dimensions = {
    FunctionName = module.lambda_function_push_report.lambda_function_name
  }
  tags = merge(
    local.tags
  )
}

## 2 Check, do we need this
#data "external" "list_of_metrics" {
#  program = ["bash", "scripts/get_list_of_tables.sh"]
#}
#
#resource "aws_cloudwatch_metric_alarm" "data_qa_test_failed_" {
#  for_each                  = toset(jsondecode(data.external.list_of_metrics.result.list_of_tables))
#  actions_enabled           = "true"
#  alarm_name                = "${local.resource_name_prefix} DATA QA found errors in ${each.value}"
#  alarm_description         = "DataQA found errors on ${each.value}, the job executed from ${data.terraform_remote_state.common_infra.outputs.airflow_web_ui}"
#  metric_name               = "suite_failed_count"
#  namespace                 = "Data-QA"
#  comparison_operator       = "GreaterThanThreshold"
#  period                    = "900"
#  threshold                 = "0"
#  evaluation_periods        = "1"
#  statistic                 = "Sum" #Average, Maximum, Sum
#  treat_missing_data        = "ignore"      #was notBreaching
#  alarm_actions             = [aws_sns_topic.guardduty.arn]
#  ok_actions                = []
#  insufficient_data_actions = []
#  dimensions = {
#    Environment = var.environment
#    table_name  = each.value
#  }
#  tags = merge(
#    local.tags
#  )
#}