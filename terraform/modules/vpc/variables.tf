variable "cidr" {
  description = "VPC cidr block"
  type        = string
}

variable "private_subnets_cidr" {
  description = "List of private subnets cidr"
  type        = list(string)
}

variable "azs" {
  description = "List of available zones in selected region"
  type        = list(string)
}

variable "qualifier" {
  description = "Qualifier used to name resources in specific format"
  type        = string
}