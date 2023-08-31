variable "network" {
  description = "Number would be used to template CIDR 10.X.0.0/16."
  type        = string
  default     = "10"
}

variable "single_nat" {
  description = "Use single Nat gateway or separeta for all AZ"
  type        = bool
  default     = true
}

variable "cluster_name" {
  type        = string
  description = "A name of the Amazon EKS cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.26"
}

variable "project" {
  type        = string
  description = "A value that will be used in annotations and tags to identify resources with the `Project` key"
}

variable "domain_name" {
  description = "Default domain name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for project"
  type        = list(any)
}

variable "environment" {
  description = "A value that will be used in annotations and tags to identify resources with the `Environment` key"
  type        = string
}

variable "cloudwatch_cluster_log_types" {
  description = "Log types that you want to send to cloudwatch"
  type        = list(any)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_cluster_log_retention_days" {
  description = "logs retention period in days (1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, 0). 0 means logs will never expire."
  type        = number
  default     = 7
}

variable "github_access_token" {
  description = "Github access token"
  type        = string
  sensitive   = true
}

variable "helm_charts" {
  description = "Helm charts used to install onto k8s cluster. Values files should be placed to ./values subfolder and have naming convention - chartname_values.yml"
  type = map(object({
    repository = string
    chart      = string
    version    = string
  }))
}

variable "s3_source_data_bucket" {
  description = "S3 bucket to read data from"
  type        = string
}
