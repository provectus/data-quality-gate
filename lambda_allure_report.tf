resource "random_uuid" "allure_report" {
  keepers = {
    for filename in setunion(
      fileset("${path.module}/functions/allure_report/", "*.py"),
      fileset("${path.module}/functions/allure_report/", "requirements.txt")
    ) :
    filename => filemd5("${path.module}/functions/allure_report/${filename}")
  }
}

module "docker_image_allure_report" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.2.1"
  create_ecr_repo = true
  ecr_repo        = "${local.resource_name_prefix}-allure-report"
  image_tag       = random_uuid.allure_report.result
  source_path     = "${path.module}/functions/allure_report/"
}

module "lambda_function_allure_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.2.1"
  function_name  = "${local.resource_name_prefix}-allure-report"
  description    = "Allure report"
  create_package = false

  environment_variables = {
    QA_BUCKET         = aws_s3_bucket.fast_data_qa.bucket
    QA_CLOUDFRONT     = aws_cloudfront_distribution.s3_distribution.domain_name
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    ENVIRONMENT       = var.environment
  }

  image_uri                      = module.docker_image_allure_report.image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = 1024
  tracing_mode                   = "PassThrough"
}