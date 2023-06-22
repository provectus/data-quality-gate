variable "cidr" {
  description = "VPC cidr block"
  type        = string
}

variable "private_subnets_cidr" {
  description = "List of private subnets cidr"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "List of private subnets cidr"
  type        = list(string)
}

variable "azs" {
  description = "List of available zones in selected region"
  type        = list(string)
}

variable "resource_name_prefix" {
  description = "Resource name prefix used to generate resources"
  type        = string
}
