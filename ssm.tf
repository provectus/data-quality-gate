
resource "aws_ssm_parameter" "data_qa_cloudfront" {
  data_type   = "text"
  description = "domain for cloudfront"
  name        = "/${local.resource_name_prefix}/data-qa/cloudfront"
  type        = "String"
  value       = local.aws_cloudfront_distribution
}

resource "aws_ssm_parameter" "data_qa_datasource_bucket" {
  data_type = "text"
  name      = "/${local.resource_name_prefix}/data-qa/datasource-bucket"
  type      = "String"
  value     = aws_s3_bucket.fast_data_qa.bucket
}

resource "aws_ssm_parameter" "data_qa_datasource_folder" {
  data_type = "text"
  name      = "/${local.resource_name_prefix}/data-qa/datasource-folder"
  type      = "String"
  value     = "data"
}

resource "aws_ssm_parameter" "data_qa_dynamo_table" {
  data_type = "text"
  name      = "/${local.resource_name_prefix}/data-qa/dynamo-table"
  type      = "String"
  value     = "${local.resource_name_prefix}-dataqareport"
}

resource "aws_ssm_parameter" "data_qa_qa_bucket" {
  data_type = "text"
  name      = "/${local.resource_name_prefix}/data-qa/qa-bucket"
  type      = "String"
  value     = aws_s3_bucket.fast_data_qa.bucket
}