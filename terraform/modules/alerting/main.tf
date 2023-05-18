resource "aws_kms_key" "slack" {
  description = "KMS key for slack webhook url"
}

resource "aws_kms_ciphertext" "slack_url" {
  plaintext = var.slack_webhook_url
  key_id    = aws_kms_key.slack.arn
}

module "slack_notification" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 5.0"

  sns_topic_name = var.slack_sns_topic_name

  slack_webhook_url = aws_kms_ciphertext.slack_url.ciphertext_blob
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username

  kms_key_arn = aws_kms_key.slack.arn
  log_events  = true

  lambda_function_name = "${var.resource_name_prefix}-${var.slack_channel}"

  lambda_function_vpc_security_group_ids = var.lambda_function_vpc_security_group_ids
  lambda_function_vpc_subnet_ids         = var.lambda_function_vpc_subnet_ids
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  for_each = data.aws_sfn_state_machine.step_functions

  alarm_name          = each.value.name
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = "notBreaching"
  period              = var.period
  namespace           = "AWS/States"
  metric_name         = "ExecutionsFailed"

  dimensions = {
    StateMachineArn = each.value.arn
  }

  alarm_actions = [module.slack_notification.slack_topic_arn]
}

data "aws_sfn_state_machine" "step_functions" {
  for_each = var.step_functions_to_monitor
  name     = each.key
}

