variable "project" {
  type    = string
  default = "demo"
}

variable "environment" {
  type    = string
  default = "data-qa-dev"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "slack_webhook_url" {
  type = string
  default = null
}