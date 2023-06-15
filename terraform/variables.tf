variable "tags" {
  description = "Default tags"
  type        = map(string)

  default = {}
}

variable "project" {
  description = "Project name used to build fully qualified tags and resource's names"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment name used to build fully qualified tags and resource's names"
  type        = string
  default     = "data-qa-dev"
}

variable "slack_settings" {
  description = "Slack notifications settings. If null - slack notifications will be disabled"
  type = object({
    webhook_url = string
    channel     = string
    username    = string
    image_uri   = string
    vpc_id      = string
  })

  default = null
}

variable "data_test_storage_bucket_name" {
  description = "Bucket name which will be used to store data tests and settings for it's execution"
  type        = string
}

variable "s3_source_data_bucket" {
  type        = string
  description = "Bucket name, with the data on which test will be executed"
}

variable "test_coverage_path" {
  description = "Path to the tests description path, relative to the root TF"
  type        = string
  default     = "../configs/test_coverage.json"
}

variable "pipeline_config_path" {
  description = "Path to the pipeline description path, relative to the root TF"
  type        = string
  default     = "../configs/pipeline.json"
}

variable "pks_path" {
  description = "Path to the primary keys description path, relative to the root TF"
  type        = string
  default     = "../configs/pks.json"
}

variable "sort_keys_path" {
  description = "Path to the sort keys description path, relative to the root TF"
  type        = string
  default     = "../configs/sort_keys.json"
}

variable "mapping_path" {
  description = "Path to the mapping description path, relative to the root TF"
  type        = string
  default     = "../configs/mapping.json"
}

variable "expectations_store" {
  description = "Path to the expectations_store directory, relative to the root TF"
  type        = string
  default     = "../expectations_store"
}

variable "cloudfront_allowed_subnets" {
  description = "list of allowed subnets allows users to get reports from specific IP address spaces"
  type        = list(string)
  default     = null
}

variable "cloudfront_location_restrictions" {
  description = "List of regions allowed for CloudFront distribution"
  type        = list(string)
  default     = ["US", "CA", "GB", "DE", "TR"]
}

variable "lambda_allure_report_memory" {
  description = "Amount of memory allocated to the lambda function lambda_allure_report"
  type        = number
  default     = 1024
}

variable "lambda_data_test_memory" {
  description = "Amount of memory allocated to the lambda function lambda_data_test"
  type        = number
  default     = 5048
}

variable "lambda_push_report_memory" {
  description = "Amount of memory allocated to the lambda function lambda_push_report"
  type        = number
  default     = 1024
}

variable "lambda_push_jira_url" {
  description = "Lambda function push report env variable JIRA_URL"
  type        = string
  default     = null
}

variable "lambda_push_secret_name" {
  description = "Lambda function push report env variable JIRA_URL"
  type        = string
  default     = null
}

variable "redshift_db_name" {
  description = "Database name for source redshift cluster"
  type        = string
  default     = null
}

variable "redshift_secret" {
  description = "Secret name from AWS SecretsManager for Redshift cluster"
  type        = string
  default     = null
}

variable "push_report_extra_vars" {
  type        = map(string)
  default     = {}
  description = "Extra variables for push report lambda"
}

variable "cloudfront_distribution_enabled" {
  type        = bool
  default     = true
  description = "Enable CloudFront distribution"
}
#DynamoDB
variable "dynamodb_table_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default     = []
}

variable "dynamodb_stream_enabled" {
  description = "Dynamodb report table stream enabled"
  type        = bool
  default     = false
}

variable "dynamodb_write_capacity" {
  description = "Dynamodb report table write capacity"
  type        = number
  default     = 2
}

variable "dynamodb_read_capacity" {
  description = "Dynamodb report table read capacity"
  type        = number
  default     = 20
}

variable "dynamodb_report_table_autoscaling_read_capacity_settings" {
  description = "Report table autoscaling read capacity"
  type = object({
    min = number
    max = number
  })

  default = {
    min = 50
    max = 200
  }
}

variable "dynamodb_report_table_autoscaling_write_capacity_settings" {
  description = "Report table autoscaling write capacity"
  type = object({
    min = number
    max = number
  })

  default = {
    min = 2
    max = 50
  }
}

variable "dynamodb_report_table_read_scale_threshold" {
  description = "Dynamodb report table read scale up threshold"
  type        = number
  default     = 60
}
variable "dynamodb_report_table_write_scale_threshold" {
  description = "Dynamodb report table write scale up threshold"
  type        = number
  default     = 70
}

#Lambda
variable "allure_report_image_uri" {
  description = "Allure report image URI(ECR repository)"
  type        = string
}
variable "data_test_image_uri" {
  description = "Data test image URI(ECR repository)"
  type        = string
}
variable "push_report_image_uri" {
  description = "Push report image URI(ECR repository)"
  type        = string
}

#Cloudwatch
variable "create_cloudwatch_notifications_topic" {
  description = "Should sns topic for cloudwatch alerts be created"
  type        = bool
  default     = true
}
variable "sns_cloudwatch_notifications_topic_arn" {
  description = "SNS topic to send cloudwatch events"
  type        = string
  default     = null
}

#Lambda
variable "vpc_subnet_ids" {
  description = "List of subnet ids to place lambda in. If null value, default subnet and vpc will be used"
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group assigned to lambda. If null value, default subnet and vpc will be used"
  type        = list(string)
  default     = null
}

variable "web_acl_id" {
  type    = string
  default = "arn:aws:wafv2:us-east-1:024975173233:global/webacl/demo-provectus-web-acl/c4517afa-629f-41ab-a4b9-a9645eb9b8dc"
}
