module "athena-connector" {
  source = "./modules/athena-connector"

  primary_aws_region = data.aws_region.current.name

  data_catalog_name = "dqg-dynamodb-connector-${var.environment}"
}

module "basic_slack_alerting" {
  count  = var.basic_alert_notification_settings == null ? 0 : 1
  source = "./modules/alerting"

  slack_channel     = var.basic_alert_notification_settings.channel
  slack_webhook_url = var.basic_alert_notification_settings.webhook_url

  slack_sns_topic_name = "dqg-basic_alerting"
  slack_username       = "DQG-alerting"

  step_functions_to_monitor = ["${local.resource_name_prefix}-fast-data-qa"]

  resource_name_prefix = local.resource_name_prefix
}

module "reports_gateway" {
  source      = "./modules/s3-gateway"
  env         = var.environment
  bucket_name = aws_s3_bucket.settings_bucket.bucket

  vpc_id             = var.reports_vpc_id
  instance_subnet_id = var.reports_subnet_id

  whitelist_ips = var.reports_whitelist_ips
}
