resource "aws_iam_policy" "basic_lambda_policy" {
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
            "s3:*"
          ],
          "Resource" : [
            "arn:aws:s3:::${aws_s3_bucket.settings_bucket.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.settings_bucket.bucket}/*",
          ]
        },
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
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:Subscribe"
          ],
          "Resource" : "*"
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
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Resource" : [
            "*",
          ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "data_test_athena" {
  name = "${local.resource_name_prefix}-data-test-athena"
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

resource "aws_iam_role_policy_attachment" "data_test_athena" {
  role       = module.lambda_function_data_test.lambda_role_name
  policy_arn = aws_iam_policy.data_test_athena.arn
}