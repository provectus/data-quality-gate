output "cloudfront_domain" {
  value = aws_cloudfront_distribution.s3_distribution_ip.domain_name
}