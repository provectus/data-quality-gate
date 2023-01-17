provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "source_data_bucket" {
  bucket_prefix = "source_data"
}

module "data_qa" {
  source                     = "../../terraform"
  cloudfront_allowed_subnets = ["255.255.255.255/32"]
  s3_source_data_bucket      = aws_s3_bucket.source_data_bucket.bucket

  environment                = "dev"

  allure_report_image_uri = ""
  data_test_image_uri = ""
  push_report_image_uri = ""
}

