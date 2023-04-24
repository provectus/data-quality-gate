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
}
