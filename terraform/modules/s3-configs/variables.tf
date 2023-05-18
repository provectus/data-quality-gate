variable "environment" {
  description = "Environment name used to build fully qualified tags and resource's names"
  type        = string
}

variable "data_test_storage_bucket_name" {
  description = "Bucket name which will be used to store data tests and settings for it's execution"
  type        = string
}

variable "test_coverage_path" {
  description = "Path to the tests description path, relative to the root TF"
  type        = string
}

variable "pipeline_config_path" {
  description = "Path to the pipeline description path, relative to the root TF"
  type        = string
}

variable "pks_path" {
  description = "Path to the primary keys description path, relative to the root TF"
  type        = string
}

variable "sort_keys_path" {
  description = "Path to the sort keys description path, relative to the root TF"
  type        = string
}

variable "mapping_path" {
  description = "Path to the mapping description path, relative to the root TF"
  type        = string
}

variable "expectations_store" {
  description = "Path to the expectations_store directory, relative to the root TF"
  type        = string
}
