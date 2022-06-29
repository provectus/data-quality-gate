resource "random_uuid" "fast_data" {
  keepers = {
    for filename in setunion(
      fileset("${path.module}/functions/data_test/", "*.py"),
      fileset("${path.module}/functions/data_test/", "requirements.txt"),
      fileset("${path.module}/functions/data_test/", "Dockerfile")
    ) :
    filename => filemd5("${path.module}/functions/data_test/${filename}")
  }
}

module "docker_image_fast_data" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = true
  ecr_repo        = "${local.resource_name_prefix}-fast-data"
  image_tag       = random_uuid.fast_data.result
  source_path     = "${path.module}/functions/data_test/"
}

module "lambda_function_fast_data" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.2.1"
  function_name  = "${local.resource_name_prefix}-fast-data"
  description    = "Fast data QA"
  create_package = false
  environment_variables = {
    QA_BUCKET         = aws_s3_bucket.fast_data_qa.bucket
    QA_CLOUDFRONT     = aws_cloudfront_distribution.s3_distribution.domain_name
    QA_DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    #CDC_BUCKET        = var.source_s3_bucket_name
    #HOODIE_CONFIG     = "${data.terraform_remote_state.common_infra.outputs.etl_task_settings}/configs/${var.environment}/hudi_config.json"
    #HUDI_DB           = data.terraform_remote_state.env-specific.outputs.processed_glue_database
    ENVIRONMENT       = var.environment
  }
  image_uri                      = module.docker_image_fast_data.image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = -1
  timeout                        = 900
  memory_size                    = 5048
  tracing_mode                   = "PassThrough"
}

resource "aws_iam_policy" "fast_data_qa_basic_lambda_policy" {
  name = "${local.resource_name_prefix}-fast-data-qa-basic"
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${local.resource_name_prefix}/data-qa/*}"
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "fast_data_qa_basic_lambda_policy" {
  role       = module.lambda_function_fast_data.lambda_role_name
  policy_arn = aws_iam_policy.fast_data_qa_basic_lambda_policy.arn
}

resource "aws_iam_policy" "fast_data_qa_athena" {
  name = "${local.resource_name_prefix}-fast-data-qa-athena"
  path = "/service-role/"
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

resource "aws_iam_role_policy_attachment" "fast_data_qa_athena" {
  role       = module.lambda_function_fast_data.lambda_role_name
  policy_arn = aws_iam_policy.fast_data_qa_athena.arn
}
## Looks like the source and destination databases could be different (not only s3 with Glue metastore,
### but some RDS and so on)
### This is why, looks like resource access must be managed outside of this module
#resource "aws_iam_policy" "fast_data_qa_read" {
#  name = "${local.resource_name_prefix}-fast-data-qa-read-s3-glue"
#  path = "/service-role/"
#  policy = jsonencode(
#    {
#      Statement = [
#        {
#          "Sid" : "GetDataBases",
#          "Effect" : "Allow",
#          "Action" : [
#            "glue:GetDataBases"
#          ],
#          "Resource" : "*"
#        },
#        {
#          "Sid" : "GetTablesActionOnBooks",
#          "Effect" : "Allow",
#          "Action" : [
#            "glue:GetTable",
#            "glue:GetTables"
#          ],
#          "Resource" : [
#            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
#            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/${data.terraform_remote_state.env-specific.outputs.processed_glue_database}",
#            "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${data.terraform_remote_state.env-specific.outputs.processed_glue_database}/*"
#          ]
#        }
#      ]
#      Version = "2012-10-17"
#    }
#  )
#}
#
#resource "aws_iam_role_policy_attachment" "fast_data_qa_read" {
#  role       = module.lambda_function_fast_data.lambda_role_name
#  policy_arn = aws_iam_policy.fast_data_qa_read.arn
#}

#resource "aws_lakeformation_permissions" "fast-data-qa-processed_db_access" {
#  principal   = aws_lambda_function.lambda_function_read_new_files.role
#  permissions = ["SELECT"]
#
#  table {
#    database_name = data.terraform_remote_state.env-specific.outputs.processed_glue_database
#    wildcard      = true
#  }
#}
#
#resource "aws_lakeformation_permissions" "processed_db_access_qa_database_access" {
#  principal   = module.lambda_function_fast_data.lambda_role_arn
#  permissions = ["DESCRIBE"]
#
#  database {
#    name = data.terraform_remote_state.env-specific.outputs.processed_glue_database
#  }
#}
#
#resource "aws_lakeformation_permissions" "processed_db_access_qa_table_access" {
#  principal   = module.lambda_function_fast_data.lambda_role_arn
#  permissions = ["SELECT"]
#
#  table {
#    database_name = data.terraform_remote_state.env-specific.outputs.processed_glue_database
#    wildcard      = true
#  }
#}