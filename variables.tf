variable "project" {
  type    = string
  default = "demo"
}

variable "environment" {
  type    = string
  default = "data-qa-dev"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "slack_webhook_url" {
  type    = string
  default = null
}

variable "cognito_user_pool_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "s3_source_data_bucket" {
  type        = string
  description = "bucket name, with the data on which test will be executed"
}

variable "test_coverage_path" {
  type        = string
  description = "Path to the tests description path, relative to the root TF"
  default     = "../configs/test_coverage.json"
}

variable "expectations_store" {
  type        = string
  description = "Path to the expectations_store directory, relative to the root TF"
  default     = "../expectations_store"
}