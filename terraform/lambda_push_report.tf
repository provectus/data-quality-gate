module "lambda_function_push_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-push-report"
  description    = "Allure report"
  create_package = false

  attach_policy = true
  policy        = aws_iam_policy.basic_lambda_policy.arn

  environment_variables = {
    QA_BUCKET         = aws_s3_bucket.settings_bucket.bucket
    QA_CLOUDFRONT     = local.aws_cloudfront_distribution
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    ENVIRONMENT       = var.environment
    JIRA_URL          = var.lambda_push_jira_url
    SECRET_NAME       = var.lambda_push_secret_name
    REGION_NAME       = data.aws_region.current.name
  }

  image_uri                      = var.push_report_image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = var.lambda_push_report_memory
  tracing_mode                   = "PassThrough"

  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids
}

resource "aws_iam_policy" "data_test_sm" {
  name = "${local.resource_name_prefix}-data-test-sm"
  path = "/service-role/"
  policy = jsonencode(
    {
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sagemaker:SendPipelineExecutionStepSuccess",
            "sagemaker:SendPipelineExecutionStepFailure"
          ],
          "Resource" : "*"
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "data_test_sm" {
  role       = module.lambda_function_push_report.lambda_role_name
  policy_arn = aws_iam_policy.data_test_sm.arn
}
