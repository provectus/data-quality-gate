variable "resource_name_prefix" {
  description = "Resource name prefix used to generate resources"
  type        = string
}

variable "bucket_name" {
  description = "Source for cloudfront distribution"
  type        = string
}

variable "allowed_ips" {
  description = "list of allowed IPs to get reports"
  type        = list(string)
}