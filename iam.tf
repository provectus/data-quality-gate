resource "aws_iam_policy" "allow_s3_bucket_read" {
  name = "${local.resource_name_prefix}-allow-s3-bucket-read"
  path = "/${var.environment}/"
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
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket",
            "s3:GetObject*"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.s3_source_data_bucket}",
            "arn:aws:s3:::${var.s3_source_data_bucket}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*"
          ],
          "Resource" : [
            "arn:aws:s3:::${aws_s3_bucket.fast_data_qa.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.fast_data_qa.bucket}/*",
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:PutMetricData"
          ],
          "Resource" : [
            "*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "allure_report_s3_lambda_policy" {
  role       = module.lambda_function_allure_report.lambda_role_name
  policy_arn = aws_iam_policy.allow_s3_bucket_read.arn
}

resource "aws_iam_policy" "allow_dynamodb" {
  name = "${local.resource_name_prefix}-allow-dynamodb"
  path = "/${var.environment}/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:ListGlobalTables",
            "dynamodb:ListTables"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "dynamodb:*",
          "Resource" : "${aws_dynamodb_table.data_qa_report.arn}"
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "push_report_dynamo_lambda_policy" {
  role       = module.lambda_function_push_report.lambda_role_name
  policy_arn = aws_iam_policy.allow_dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "fast_data_s3_lambda_policy" {
  role       = module.lambda_function_fast_data.lambda_role_name
  policy_arn = aws_iam_policy.allow_s3_bucket_read.arn
}

resource "aws_iam_role_policy_attachment" "push_report_s3_lambda_policy" {
  role       = module.lambda_function_push_report.lambda_role_name
  policy_arn = aws_iam_policy.allow_s3_bucket_read.arn
}

#resource "aws_iam_role" "read_new_files_s3_lambda_role" {
#  name               = "${local.resource_name_prefix}-read-new-files-s3"
#  assume_role_policy = data.aws_iam_policy_document.read_new_files_s3_lambda.json
#}

#data "aws_iam_policy_document" "read_new_files_s3_lambda" {
#  statement {
#    principals {
#      type        = "Service"
#      identifiers = ["lambda.amazonaws.com"]
#    }
#
#    actions = ["sts:AssumeRole"]
#  }
#}

#resource "aws_iam_role_policy_attachment" "read_new_files_s3_lambda_policy" {
#  role       = aws_iam_role.read_new_files_s3_lambda_role.id
#  policy_arn = aws_iam_policy.allow_s3_bucket_read.arn
#}

resource "aws_iam_policy" "athena_dynamodb_connection_basic_lambda_policy" {
  name        = "${local.resource_name_prefix}-athena-dynamodb-connection-basic-lambda-policy"
  description = "Provides write permissions to CloudWatch Logs."
  path        = "/${var.environment}/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "airflow_start_step_functions" {
  name        = "${local.resource_name_prefix}-airflow-start-step-functions"
  description = "Provides permissions to trigger Step Functions."
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "states:StartExecution"
        ],
        "Resource" : [
          aws_sfn_state_machine.fast_data_qa.arn
        ]
      },
      {
        "Action" : [
          "states:DescribeExecution"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:execution:${aws_sfn_state_machine.fast_data_qa.name}:*"
        ]
      }
    ]
  })
}




