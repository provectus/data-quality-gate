variable "slack_sns_topic_name" {
  description = "Sns topic name to forward notifications to"
  type        = string
}
variable "slack_webhook_url" {
  description = "Slack webhook url in form https://hooks.slack.com/services/........"
  type        = string
}
variable "slack_channel" {
  description = "Slack channel to send notifications"
  type        = string
}
variable "slack_username" {
  description = "Slack username which will be used as author of notifications"
  type        = string
}

variable "resource_name_prefix" {
  description = "Resource name prefix used to generate resources"
  type        = string
}

variable "step_functions_to_monitor" {
  description = "List of step functions for which to create cloudwatch metrics alarm"
  type        = set(string)
  default     = []
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied."
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold."
  type        = number
  default     = 1
}

variable "datapoints_to_alarm" {
  description = "The number of datapoints that must be breaching to trigger the alarm."
  type        = number
  default     = 1
}

variable "lambda_function_vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "lambda_function_vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}
