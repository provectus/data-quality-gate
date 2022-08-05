terraform {
  backend "s3" {
  }
}

resource "aws_s3_bucket" "source_data_bucket" {
  bucket_prefix = "demo-data-quality-gate-source-ip"
}

module "data_qa_gate" {
  source                     = "../"
  cloudfront_allowed_subnets = ["195.155.100.203/32"]
  s3_source_data_bucket      = aws_s3_bucket.source_data_bucket.bucket
  environment                = "test-ip"
}

