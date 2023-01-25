variable "aws_region" {}
variable "aws_caller_identity" {}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Map of AWS Resource TAG's which will be added to each resource"
}

variable "prefix" {
  type        = string
  description = "Resource string prefix"
}

variable "webhook_url" {
  type = string
}

variable "slack_channel" {
  type        = string
  description = "Slack channel where to put cloudwatch alerts"
}

variable "slack_username" {
  type        = string
  description = "Slack username which will be used to announce cloudwatch alerts"
}

variable "sns_topic_arn" {
  type        = string
  description = "Name of existed sns topic to track"
}
