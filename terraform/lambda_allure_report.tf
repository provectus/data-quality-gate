module "lambda_allure_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-allure-report"
  description    = "Allure report"
  create_package = false

  attach_policy = true
  policy        = aws_iam_policy.basic_lambda_policy.arn

  environment_variables = {
    ENVIRONMENT    = var.environment
    BUCKET         = module.s3_bucket.bucket_name
    REPORTS_WEB    = module.reports_gateway.s3_gateway_address
    DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
  }

  image_uri                      = var.allure_report_image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_allure_report_memory
  tracing_mode                   = "PassThrough"

  vpc_subnet_ids         = var.lambda_private_subnet_ids
  vpc_security_group_ids = var.lambda_security_group_ids
}