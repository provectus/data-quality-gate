module "lambda_data_test" {
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

resource "aws_iam_policy" "athena" {
  name = "${local.resource_name_prefix}-data-test-athena"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetWorkGroup",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution",
            "athena:GetQueryExecution",
            "athena:GetQueryResults"
          ],
          "Resource" : "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:workgroup/primary"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject",
            "s3:AbortMultipartUpload",
            "s3:ListMultipartUploadParts"
          ],
          "Resource" : "arn:aws:s3:::aws-athena-query-results-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "athena:ListWorkGroups",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource" : "arn:aws:s3:::aws-athena-query-results-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "data_test_athena" {
  role       = module.lambda_data_test.lambda_role_name
  policy_arn = aws_iam_policy.athena.arn
}
