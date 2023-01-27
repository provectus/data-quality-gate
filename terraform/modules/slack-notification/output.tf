output "slack_sns_arn" {
  value = join("", aws_sns_topic.slack_notification.*.arn)
}

