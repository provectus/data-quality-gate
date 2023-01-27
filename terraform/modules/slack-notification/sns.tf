resource "aws_sns_topic_subscription" "slack_notification_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notification.arn
}
