data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resource_name_prefix = "${var.project}-${var.environment}"
}
