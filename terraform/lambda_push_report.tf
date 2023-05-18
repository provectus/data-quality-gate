locals {
  default_push_report_env_vars = {
    ENVIRONMENT    = var.environment
    BUCKET         = aws_s3_bucket.settings_bucket.bucket
    REPORTS_WEB    = module.reports_gateway.s3_gateway_address
    DYNAMODB_TABLE = aws_dynamodb_table.data_qa_report.name
    JIRA_URL       = var.lambda_push_jira_url
    SECRET_NAME    = var.lambda_push_secret_name
    REGION_NAME    = data.aws_region.current.name
  }
}

module "lambda_push_report" {
  source         = "terraform-aws-modules/lambda/aws"
  version        = "3.3.1"
  function_name  = "${local.resource_name_prefix}-push-report"
  description    = "Push report"
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

  vpc_subnet_ids         = var.lambda_private_subnet_ids
  vpc_security_group_ids = var.lambda_security_group_ids
}

module "data_reports_alerting" {
  count  = var.data_reports_notification_settings == null ? 0 : 1
  source = "./modules/alerting"

  slack_channel     = var.data_reports_notification_settings.channel
  slack_webhook_url = var.data_reports_notification_settings.webhook_url

  slack_sns_topic_name = "dqg-data_reports-${var.environment}"
  slack_username       = "DQG-alerting"

  resource_name_prefix = local.resource_name_prefix
}

resource "aws_iam_policy" "dynamodb" {
  name = "${local.resource_name_prefix}-dynamodb"
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
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "dynamodb:*",
          "Resource" : aws_dynamodb_table.data_qa_report.arn
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "push_report_dynamodb" {
  role       = module.lambda_push_report.lambda_role_name
  policy_arn = aws_iam_policy.dynamodb.arn
}


resource "aws_iam_policy" "sns" {
  count = length(module.data_reports_alerting) == 1 ? 1 : 0
  name  = "${local.resource_name_prefix}-sns"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : module.data_reports_alerting[0].sns_topic_arn
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role_policy_attachment" "push_report_sns" {
  count      = length(module.data_reports_alerting) == 1 ? 1 : 0
  role       = module.lambda_push_report.lambda_role_name
  policy_arn = aws_iam_policy.sns[0].arn
}
