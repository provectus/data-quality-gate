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
}

variable "data_test_storage_bucket_name" {
  description = "Bucket name which will be used to store data tests and settings for it's execution"
  type        = string
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

variable "manifest_path" {
  description = "Path to the manifests"
  type        = string
  default     = "../configs/manifest.json"
}

variable "great_expectation_path" {
  description = "Path to the great expectations yaml"
  type        = string
  default     = "../templates/great_expectations.yml"
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

#DynamoDB
variable "dynamodb_hash_key" {
  description = "The attribute to use as the hash (partition) key. Must also be defined as an attribute"
  type        = string
  default     = "file"
}

variable "dynamodb_table_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default = [{
    name = "file"
    type = "S"
  }]
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

variable "dynamodb_autoscaling_defaults" {
  description = "A map of default autoscaling settings"
  type        = map(string)
  default = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
  }
}

variable "dynamodb_autoscaling_read" {
  description = "A map of read autoscaling settings. `max_capacity` is the only required key."
  type        = map(string)
  default = {
    max_capacity = 200
  }
}

variable "dynamodb_autoscaling_write" {
  description = "A map of write autoscaling settings. `max_capacity` is the only required key."
  type        = map(string)
  default = {
    max_capacity = 10
  }
}

#Lambda
variable "push_report_extra_vars" {
  description = "Extra environment variables for push report lambda"
  type        = map(string)
  default     = {}
}

variable "data_test_extra_vars" {
  description = "Extra environment variables for data test lambda"
  type        = map(string)
  default     = {}
}

variable "allure_report_extra_vars" {
  description = "Extra environment variables for allure report lambda"
  type        = map(string)
  default     = {}
}

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

variable "lambda_alerts_sns_topic_arn" {
  description = "SNS topic used to to publish cloudwatch alerts"
  type        = string
  default     = null
}

variable "lambda_private_subnet_ids" {
  description = "List of private subnets assigned to lambda"
  type        = list(string)
}

variable "lambda_security_group_ids" {
  description = "List of security group assigned to lambda"
  type        = list(string)
}

variable "basic_alert_notification_settings" {
  description = "Base alert notifications settings. If empty - basic alerts will be disabled"
  type = object({
    channel     = string
    webhook_url = string
  })

  default = null
}

variable "data_reports_notification_settings" {
  description = "Data reports notifications settings. If empty - notifications will be disabled"
  type = object({
    channel     = string
    webhook_url = string
  })

  default = null
}

variable "reports_whitelist_ips" {
  description = "List of allowed IPs to see reports"
  type        = list(string)
}

variable "reports_vpc_id" {
  description = "Vpc Id where gateway instance will be placed"
  type        = string
}

variable "reports_subnet_id" {
  description = "Subnet id where gateway instance will be placed"
  type        = string
}
