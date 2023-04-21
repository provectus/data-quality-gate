module "athena-connector" {
  source = "./modules/athena-connector"

  primary_aws_region   = data.aws_region.current.name
  resource_name_prefix = local.resource_name_prefix

  athena_dynamodb_connector_name = "DQG-dynamodb-connector-${var.environment}"
}

module "basic_slack_alerting" {
  count  = var.basic_alert_notification_settings == null ? 0 : 1
  source = "./modules/alerting"

  slack_channel     = var.basic_alert_notification_settings.channel
  slack_webhook_url = var.basic_alert_notification_settings.webhook_url

  slack_sns_topic_name = "dqg-basic_alerting"
  slack_username       = "DQG-alerting"

  step_functions_to_monitor = ["${local.resource_name_prefix}-fast-data-qa"]
}

module "data_reports_alerting" {
  count  = var.data_reports_notification_settings == null ? 0 : 1
  source = "./modules/alerting"

  slack_channel     = var.data_reports_notification_settings.channel
  slack_webhook_url = var.data_reports_notification_settings.webhook_url

  slack_sns_topic_name = "dqg-data_reports"
  slack_username       = "DQG-alerting"
}
