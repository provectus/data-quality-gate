resource "aws_sns_topic_subscription" "slack_notification_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notification.arn
}

resource "aws_lambda_function" "slack_notification" {
  function_name = local.lambda_function_name
  memory_size   = var.memory_size
  role          = aws_iam_role.slack_notification.arn
  package_type  = var.package_type
  image_uri     = var.image_uri

  timeout = 30

  environment {
    variables = var.lambda_env_variables
  }

  image_config {
    command = [var.handler_name]
  }

  tags = local.tags

  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.slack_notification.id]
  }
}

resource "aws_lambda_function_event_invoke_config" "slack_notification" {
  function_name                = aws_lambda_function.slack_notification.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}

resource "aws_security_group" "slack_notification" {
  name        = "${local.lambda_function_name}-sg"
  description = "Allow slack-notification lambda access to webhook endpoints"
  vpc_id      = var.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "slack_notification_https_egress" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  description       = "Allow HTTPS from lambda to webhook endpoints"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.slack_notification.id
}

resource "aws_cloudwatch_event_rule" "slack_notification" {
  for_each      = var.cloudwatch_event_rule
  name          = "${local.lambda_function_name}-${each.key}"
  description   = "${local.lambda_function_name} ${each.key} cloudwatch event rule"
  event_pattern = <<EOF
{
  "source": [
    "${each.value.source}"
  ],
  "detail-type": [
    "${each.value.detail_type}"
  ],
  "resources": [
    "${each.value.resources}"
  ]
}
  EOF
}

resource "aws_cloudwatch_event_target" "slack_notification" {
  for_each  = var.cloudwatch_event_rule
  rule      = aws_cloudwatch_event_rule.slack_notification[each.key].name
  target_id = "slack_notification"
  arn       = aws_lambda_function.slack_notification.arn
}

resource "aws_lambda_permission" "slack_notification" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

resource "aws_cloudwatch_log_group" "slack_notification" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 7
  tags              = local.tags
}
