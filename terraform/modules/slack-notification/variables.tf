variable "vpc_id" {
  description = "Vpc id that this module runs on"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ids where slack lambda will be placed."
  type        = list(string)
}

variable "sns_topic_arn" {
  type        = string
  description = "Existed sns topic to forward messages from."
}

variable "primary_aws_region" {
  description = "The region of the primary devops bucket"
  type        = string
  default     = "us-west-2"
}

variable "slack_notification_service_name" {
  description = "The name of the slack notification service. Used to create the sns topic name"
  type        = string
  default     = "sre-high-urgency"
}

variable "cloudwatch_event_rule" {
  type = map(object({
    source      = string
    detail_type = string
    resources   = string
  }))

  default     = {}
  description = "The cloudwatch event rule configuration"
}

variable "lambda_env_variables" {
  description = "Environment variables for the lambda"
  type        = map(string)
}

variable "handler_name" {
  description = "The name of the handler"
  type        = string
  default     = "slack_notification.lambda_handler"
}

variable "memory_size" {
  description = "The amount of memory the canary should use"
  type        = string
  default     = "128"
}

variable "package_type" {
  description = "The package type for the lambda function ('Image' or 'Zip')"
  type        = string
  default     = "Image"
}

variable "image_uri" {
  description = "The URI for the ECR image to use with the lambda function"
  type        = string
}