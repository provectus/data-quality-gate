output "sns_topic_arn" {
  description = "Notifications topic arn"
  value       = module.slack_notification.slack_topic_arn
}
