resource "aws_s3_bucket" "athena_spill_bucket" {
  bucket = "${var.resource_name_prefix}_athena"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = false
  }
}

resource "aws_lambda_function" "athena_dynamodb_connector" {
  function_name = "${var.resource_name_prefix}_athena_dynamodb_connector"
  description   = "Enables Amazon Athena to communicate with DynamoDB, making tables accessible via SQL"

  role     = aws_iam_role.athena_connector_lambda_role.arn
  filename = "${path.module}/../artifacts/aws-athena-dynamodb-connector.zip"

  runtime = "java11"
  handler = "com.amazonaws.athena.connectors.dynamodb.DynamoDBCompositeHandler"

  timeout      = 900
  memory_size  = 3008
  package_type = "Zip"

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  environment {
    variables = {
      disable_spill_encryption = "false"
      spill_bucket             = aws_s3_bucket.athena_spill_bucket.bucket
      spill_prefix             = "athena-spill"
    }
  }
}

resource "aws_iam_role" "athena_connector_lambda_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "athena_connector_lambda_policy" {
  name = "${var.resource_name_prefix}-athena_connector-lambda"
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

resource "null_resource" "athena_dynamodb_connector" {
  provisioner "local-exec" {
    command = "aws create-data-catalog --name ${var.athena_dynamodb_connector_name} --type LAMBDA --tags ${var.tags} --region ${var.primary_aws_region} --parameters {'function': '${aws_lambda_function.athena_dynamodb_connector.arn}'}"
  }

  depends_on = [aws_lambda_function.athena_dynamodb_connector]
}

resource "null_resource" "delete_athena_dynamodb_connector" {
  count = var.delete_athena_dynamodb_connector ? 1 : 0
  provisioner "local-exec" {
    command = "aws delete-data-catalog --name ${var.athena_dynamodb_connector_name} --region ${var.primary_aws_region}"
  }

  depends_on = [null_resource.athena_dynamodb_connector]
}