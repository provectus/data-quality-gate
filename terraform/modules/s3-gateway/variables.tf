variable "env" {
  description = "Env tag used to tag resources"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name to serve by gateway(read-only)"
  type        = string
}

variable "vpc_id" {
  description = "VpcId for s3 gateway"
  type        = string
}

variable "whitelist_ips" {
  description = "Allowed IPs to ssh/http to host"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type for s3 gateway"
  type        = string
  default     = "t2.micro"
}

variable "instance_subnet_id" {
  description = "Instance subnet id"
  type        = string
}

variable "instance_sg_ids" {
  description = "Extra list of security groups for instance"
  type        = list(string)
  default     = []
}
