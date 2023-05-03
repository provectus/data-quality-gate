resource "aws_iam_role" "athena_connector_lambda_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "athena_connector_lambda_policy" {
  name = "${var.data_catalog_name}-lambda"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Resource" : "*",
          "Action" : [
            "dynamodb:DescribeTable",
            "dynamodb:ListSchemas",
            "dynamodb:ListTables",
            "dynamodb:Query",
            "dynamodb:Scan",
            "glue:GetTableVersions",
            "glue:GetPartitions",
            "glue:GetTables",
            "glue:GetTableVersion",
            "glue:GetDatabases",
            "glue:GetTable",
            "glue:GetPartition",
            "glue:GetDatabase",
            "athena:GetQueryExecution",
            "s3:ListAllMyBuckets"
          ],
        },
        {
          "Effect" : "Allow",
          "Resource" : "*",
          "Action" : [
            "cloudwatch:PutMetricData",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ]
        },
        {
          "Effect" : "Allow",
          "Resource" : [
            aws_s3_bucket.athena_spill_bucket.arn,
            "${aws_s3_bucket.athena_spill_bucket.arn}/*"
          ],
          "Action" : [
            "s3:GetObject",
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:GetObjectVersion",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetLifecycleConfiguration",
            "s3:PutLifecycleConfiguration",
            "s3:DeleteObject"
          ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "athena_connector_basic_policy" {
  role       = aws_iam_role.athena_connector_lambda_role.name
  policy_arn = aws_iam_policy.athena_connector_lambda_policy.arn
}