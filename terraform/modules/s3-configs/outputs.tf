output "bucket_name" {
  description = "Name of s3 configs bucket"
  value       = aws_s3_bucket.settings_bucket.bucket
}
