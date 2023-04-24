variable "slack_sns_topic_name" { type = string }
variable "slack_webhook_url" { type = string }
variable "slack_channel" { type = string }
variable "slack_username" { type = string }

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
