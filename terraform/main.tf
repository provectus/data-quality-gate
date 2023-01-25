data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"
}

module "slack_notifications" {
  count = var.slack_settings == null ? 0 : 1

  source = "./modules/slack"
  prefix = local.resource_name_prefix

  aws_region          = data.aws_region.current.name
  aws_caller_identity = data.aws_caller_identity.current.id

  webhook_url = var.slack_settings.webhook_url

  slack_channel  = var.slack_settings.channel
  slack_username = var.slack_settings.username

  sns_topic_arn = var.sns_topic_notifications_arn
}