resource "random_uuid" "push_report" {
  keepers = {
    for filename in setunion(
      fileset("${path.module}/functions/report_push/", "*.py"),
      fileset("${path.module}/functions/report_push/", "requirements.txt"),
      fileset("${path.module}/functions/report_push/", "Dockerfile")
    ) :
    filename => filemd5("${path.module}/functions/report_push/${filename}")
  }
}

module "docker_image_push_report" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = true
  ecr_repo        = "${local.resource_name_prefix}-push-report"
  image_tag       = random_uuid.push_report.result
  source_path     = "${path.module}/functions/report_push"
}

module "lambda_function_push_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-push-report"
  description    = "Allure report"
  create_package = false
  environment_variables = merge(var.push_report_extra_vars, {
    QA_BUCKET         = aws_s3_bucket.fast_data_qa.bucket
    QA_CLOUDFRONT     = local.aws_cloudfront_distribution
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    ENVIRONMENT       = var.environment
    JIRA_URL          = var.lambda_push_jira_url
    SECRET_NAME       = var.lambda_push_secret_name
    REGION_NAME       = data.aws_region.current.name
  })
  image_uri                      = module.docker_image_push_report.image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_push_report_memory
  tracing_mode                   = "PassThrough"
  ephemeral_storage_size         = var.lambda_push_report_ephemeral_storage_size
}
