variable "resource_name_prefix" {
  description = "Resource name prefix used to generate resources"
  type        = string
}

variable "primary_aws_region" {
  description = "AWS region"
  type        = string
}

variable "delete_athena_dynamodb_connector" {
  description = "Set to True to delete athena dynamodb connector"
  type        = bool
  default     = false
}

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