output "s3_gateway_address" {
  description = "DNS http address of s3 gateway"
  value       = replace(aws_instance.s3_gateway.public_dns, "https", "http")
}
