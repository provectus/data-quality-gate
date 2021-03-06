terraform {
  backend "s3" {
  }
}

resource "aws_s3_bucket" "source_data_bucket" {
  bucket_prefix = "demo-data-quality-gate-source"
}

module "data_qa_gate" {
  source = "../"
  aws_region = "eu-central-1"
  s3_source_data_bucket = aws_s3_bucket.source_data_bucket.bucket
}

