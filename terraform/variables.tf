variable "project" {
  type    = string
  default = "demo"
}

variable "environment" {
  type    = string
  default = "data-qa-dev"
}

variable "slack_settings" {
  type = object({
    webhook_url = string
    channel     = string
    username    = string
  })

  default     = null
  description = "Slack notifications settings"
}

variable "sns_topic_notifications_arn" {
  type        = string
  default     = null
  description = "SNS topic to send cloudwatch events"
}

variable "data_test_storage_bucket_name" {
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

variable "lambda_data_test_memory" {
  description = "Amount of memory allocated to the lambda function lambda_data_test"
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

#DynamoDB
variable "dynamodb_table_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default     = []
}

variable "dynamodb_stream_enabled" {
  type    = bool
  default = false
}

variable "dynamodb_write_capacity" {
  type        = number
  description = "Dynamodb data qa report table write capacity"
  default     = 2
}

variable "dynamodb_read_capacity" {
  type        = number
  description = "Dynamodb data qa report table read capacity"
  default     = 20
}

variable "dynamodb_report_table_autoscaling_read_capacity_settings" {
  description = "Autoscaling read capacity"
  type = object({
    min = number
    max = number
  })

  default = object({
    min = 50
    max = 200
  })
}

variable "dynamodb_report_table_autoscaling_write_capacity_settings" {
  description = "Autoscaling write capacity"
  type = object({
    min = number
    max = number
  })

  default = object({
    min = 2
    max = 50
  })
}

variable "dynamodb_report_table_read_scale_threshold" {
  type    = number
  default = 60
}
variable "dynamodb_report_table_write_scale_threshold" {
  type    = number
  default = 70
}

#Lambda
variable "allure_report_image_uri" { type = string }
variable "data_test_image_uri" { type = string }
variable "push_report_image_uri" { type = string }