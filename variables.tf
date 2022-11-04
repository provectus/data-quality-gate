variable "project" {
  type        = string
  default     = "demo"
  description = "Name of your project, will be used as a prefix for AWS resources names"
}

variable "environment" {
  type        = string
  default     = "data-qa-dev"
  description = "Additional AWS Resource prefix for all resource name, e.g. project-environment"
}

variable "slack_webhook_url" {
  type        = string
  default     = null
  description = "The Slack webhook url, which will be used to send notification if some errors will be found it datasets"
}

variable "cognito_user_pool_id" {
  type        = string
  default     = null
  description = "If you already has Cognito user pool which will be used for authentication, you could provide Cognito user pool id here. If it not provided, new Cognito user pool will be created"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Map of AWS Resource TAG's which will be added to each resource"
}

variable "s3_source_data_bucket" {
  type        = string
  description = "Bucket name, with the data on which test will be executed"
}

variable "test_coverage_path" {
  type        = string
  description = "Path to the tests description path, relative to the root TF"
  default     = "configs/test_coverage.json"
}

variable "pipeline_config_path" {
  type        = string
  description = "Path to the pipeline description path, relative to the root TF"
  default     = "configs/pipeline.json"
}

variable "pks_path" {
  type        = string
  description = "Path to the primary keys description path, relative to the root TF"
  default     = "configs/pks.json"
}

variable "sort_keys_path" {
  type        = string
  description = "Path to the sort keys description path, relative to the root TF"
  default     = "configs/sort_keys.json"
}

variable "mapping_path" {
  type        = string
  description = "Path to the mapping description path, relative to the root TF"
  default     = "configs/mapping.json"
}

variable "expectations_store" {
  type        = string
  description = "Path to the expectations_store directory, relative to the root TF"
  default     = "expectations_store"
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

variable "lambda_push_jira_url" {
  type        = string
  default     = null
  description = "Lambda function push report env variable JIRA_URL"
}

variable "lambda_push_secret_name" {
  type        = string
  default     = null
  description = "Lambda function push report env variable JIRA_URL"
}

variable "redshift_db_name" {
  type        = string
  default     = null
  description = "db name for redshift"
}

variable "redshift_secret" {
  type        = string
  default     = null
  description = "secret name from Secret Manager for Redshift cluster"
}