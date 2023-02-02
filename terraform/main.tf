data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"

  cloudfront_origin_name = "${local.resource_name_prefix}-s3-origin"
  cloudwatch_prefix      = replace(title(replace(local.resource_name_prefix, "-", " ")), " ", "")

  aws_cloudfront_distribution = var.cloudfront_allowed_subnets != null ? aws_cloudfront_distribution.s3_distribution_ip.domain_name : "fake_domain.org"

  sns_topic_notifications_arn = var.create_cloudwatch_notifications_topic ? aws_sns_topic.notifications[0].arn : var.sns_cloudwatch_notifications_topic_arn
}

module "slack_notifier" {
  count  = var.slack_settings == null ? 0 : 1
  source = "./modules/slack-notification"

  image_uri = var.slack_settings.image_uri

  lambda_env_variables = {
    SLACK_WEBHOOK_URL = var.slack_settings.webhook_url
    SLACK_CHANNEL     = var.slack_settings.channel
    SLACK_USERNAME    = var.slack_settings.username
  }

  primary_aws_region = data.aws_region.current.name
  sns_topic_arn      = local.sns_topic_notifications_arn
  subnet_ids         = var.vpc_subnet_ids

  vpc_id = var.slack_settings.vpc_id
}