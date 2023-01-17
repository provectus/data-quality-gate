module "lambda_function_allure_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-allure-report"
  description    = "Allure report"
  create_package = false

  attach_policy = true
  policy        = aws_iam_policy.basic_lambda_policy.arn

  environment_variables = {
    QA_BUCKET         = aws_s3_bucket.settings_bucket.bucket
    QA_CLOUDFRONT     = local.aws_cloudfront_distribution
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    ENVIRONMENT       = var.environment
  }

  image_uri                      = var.allure_report_image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_allure_report_memory
  tracing_mode                   = "PassThrough"
}