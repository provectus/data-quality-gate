variable "slack_sns_topic_name" { type = string }
variable "slack_webhook_url" { type = string }
variable "slack_channel" { type = string }
variable "slack_username" { type = string }

variable "resource_name_prefix" {
  description = "Resource name prefix used to generate resources"
  type        = string
}

variable "step_functions_to_monitor" {
  type    = set(string)
  default = []
}

variable "period" {
  default     = 60
  description = "The period in seconds over which the specified statistic is applied."
}

variable "evaluation_periods" {
  default     = 1
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "datapoints_to_alarm" {
  default     = 1
  description = "The number of datapoints that must be breaching to trigger the alarm."
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
