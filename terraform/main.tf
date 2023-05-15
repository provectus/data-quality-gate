data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"
  cloudwatch_prefix    = replace(title(replace(local.resource_name_prefix, "-", " ")), " ", "")
}
