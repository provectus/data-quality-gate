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

module "vpc" {
  count  = var.vpc_to_create == null ? 0 : 1
  source = "./modules/vpc"

  resource_name_prefix = local.resource_name_prefix

  cidr                 = var.vpc_to_create.cidr
  private_subnets_cidr = var.vpc_to_create.private_subnets_cidr
  azs                  = data.aws_availability_zones.available.zone_ids
}
