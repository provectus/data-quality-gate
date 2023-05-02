resource "aws_lambda_function" "athena_dynamodb_connector" {
  function_name = var.data_catalog_name
  description   = "Enables Amazon Athena to communicate with DynamoDB, making tables accessible via SQL"

  role     = aws_iam_role.athena_connector_lambda_role.arn
  filename = "${path.module}/../../artifacts/aws-athena-dynamodb-connector.zip"

  runtime = "java11"
  handler = "com.amazonaws.athena.connectors.dynamodb.DynamoDBCompositeHandler"

  timeout      = 900
  memory_size  = 3008
  package_type = "Zip"

  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && var.vpc_security_group_ids != null ? [true] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  environment {
    variables = {
      disable_spill_encryption = "false"
      spill_bucket             = aws_s3_bucket.athena_spill_bucket.bucket
      spill_prefix             = "athena-spill"
    }
  }
}

resource "null_resource" "athena_dynamodb_connector" {
  provisioner "local-exec" {
    command = "aws athena create-data-catalog --name ${var.data_catalog_name} --type LAMBDA --region ${var.primary_aws_region} --parameters function=${aws_lambda_function.athena_dynamodb_connector.arn}"
  }

  depends_on = [aws_lambda_function.athena_dynamodb_connector]
}

resource "null_resource" "delete_athena_dynamodb_connector" {
  count = var.delete_athena_dynamodb_connector ? 1 : 0
  provisioner "local-exec" {
    command = "aws athena delete-data-catalog --name ${var.data_catalog_name} --region ${var.primary_aws_region}"
  }

  depends_on = [null_resource.athena_dynamodb_connector]
}