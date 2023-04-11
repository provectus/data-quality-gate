output "s3_gateway_address" {
  value = replace(aws_instance.s3_gateway.public_dns, "https", "http")
}
