locals {
  default_push_report_env_vars = {
    QA_BUCKET         = aws_s3_bucket.settings_bucket.bucket
    QA_CLOUDFRONT     = local.aws_cloudfront_distribution
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    ENVIRONMENT       = var.environment
    JIRA_URL          = var.lambda_push_jira_url
    SECRET_NAME       = var.lambda_push_secret_name
    REGION_NAME       = data.aws_region.current.name
  }

  lambda_vpc_subnet_ids = var.vpc_to_create == null ? var.vpc_subnet_ids : module.vpc[0].private_subnet_ids
  lambda_vpc_sg_ids     = var.vpc_to_create == null ? var.vpc_security_group_ids : module.vpc[0].security_group_ids
}

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

  vpc_subnet_ids         = local.lambda_vpc_subnet_ids
  vpc_security_group_ids = local.lambda_vpc_sg_ids
}

module "lambda_function_data_test" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-data-test"
  description    = "Data test"
  create_package = false

  attach_policy = true
  policy        = aws_iam_policy.basic_lambda_policy.arn

  environment_variables = {
    QA_BUCKET         = aws_s3_bucket.settings_bucket.bucket
    QA_CLOUDFRONT     = local.aws_cloudfront_distribution
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    REDSHIFT_DB       = var.redshift_db_name
    REDSHIFT_SECRET   = var.redshift_secret
    ENVIRONMENT       = var.environment
  }

  image_uri                      = var.data_test_image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_data_test_memory
  tracing_mode                   = "PassThrough"

  vpc_subnet_ids         = local.lambda_vpc_subnet_ids
  vpc_security_group_ids = local.lambda_vpc_sg_ids
}

module "lambda_function_push_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-push-report"
  description    = "Allure report"
  create_package = false

  attach_policy = true
  policy        = aws_iam_policy.basic_lambda_policy.arn

  environment_variables = merge(local.default_push_report_env_vars, length(module.data_reports_alerting) == 1 ? { SNS_BUGS_TOPIC_ARN = module.data_reports_alerting[0].sns_topic_arn } : {})

  image_uri                      = var.push_report_image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_push_report_memory
  tracing_mode                   = "PassThrough"

  vpc_subnet_ids         = local.lambda_vpc_subnet_ids
  vpc_security_group_ids = local.lambda_vpc_sg_ids
}