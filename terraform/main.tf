data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"

  cloudfront_origin_name = "${local.resource_name_prefix}-s3-origin"
  cloudwatch_prefix      = replace(title(replace(local.resource_name_prefix, "-", " ")), " ", "")

  aws_cloudfront_distribution = var.cloudfront_allowed_subnets != null ? module.cloudfront_reports[0].cloudfront_domain : "fake_domain.org"

  sns_topic_notifications_arn = var.create_cloudwatch_notifications_topic ? aws_sns_topic.notifications[0].arn : var.sns_cloudwatch_notifications_topic_arn
}
