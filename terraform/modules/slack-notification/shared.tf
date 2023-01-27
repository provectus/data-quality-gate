locals {
  tags = {
    Name                = local.lambda_function_name
    role                = "${var.stack_prefix} Slack Notification"
    account             = var.account
    application         = var.application
    owner               = var.owner
    sponsor             = var.sponsor
    data-classification = var.data-classification
    cost-center         = var.cost_center
    environment         = var.environment
    client              = var.client
  }

  lambda_function_name = var.slack_notification_service_name == "sre-high-urgency" ? "${var.stack_prefix}-slack-notification" : "${var.stack_prefix}-${var.slack_notification_service_name}-slack-notification"

  aws_cloudwatch_metric_alarm_name = "${local.lambda_function_name}-failed"
}

data "aws_kms_key" "stack_cmk_sns_cloudwatch" {
  key_id = "arn:aws:kms:${var.primary_aws_region}:${data.aws_caller_identity.current.account_id}:alias/${var.stack_prefix}-sns-cloudwatch"
}

data "aws_caller_identity" "current" {
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.stack_prefix}-vpc"
  }
}

data "aws_subnet" "private_subnet" {
  count  = 2
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "${var.stack_prefix}-PrivateSubnet${count.index}"
  }
}
