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

variable "cloudfront_allowed_subnets" {
  type        = list(string)
  default     = null
  description = "list of allowed subnets, suitable if you wan't use Cognito and allow users to get reports from specific IP address spaces"
}

variable "cloudfront_location_restrictions" {
  default     = ["US", "CA", "GB", "DE", "TR"]
  description = "List of regions allowed for CloudFront distribution"
}

variable "lambda_allure_report_memory" {
  description = "Amount of memory allocated to the lambda function lambda_allure_report"
  default     = 1024
}

variable "lambda_fast_data_qa_memory" {
  description = "Amount of memory allocated to the lambda function lambda_fast_data_qa"
  default     = 5048
}

variable "lambda_push_report_memory" {
  description = "Amount of memory allocated to the lambda function lambda_push_report"
  default     = 1024
}