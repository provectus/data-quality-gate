variable "account" {
  description = "The account. Allowable values for this are services, dev, prod, security"
  type        = string
}

variable "client" {
  description = "The name of the client using the resources in this module"
  type        = string
  default     = "internal"
}

variable "cost_center" {
  description = "The cost center attached to the resources in this module"
  type        = string
  default     = "none"
}

variable "aws_account_id" {
  description = "The id of the account we are standing the cluster up in"
  type        = string
}

variable "primary_aws_region" {
  description = "The region of the primary devops bucket"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "vpc id that this module runs on"
  type        = string
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

  default = {
    SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
    SLACK_CHANNEL     = "#on-call-sre"
    SLACK_USERNAME    = "slack_notifier"
  }
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
  default     = "006604769879.dkr.ecr.us-west-2.amazonaws.com/a3-digital/slack-notification-lambda-python:1.0"
}