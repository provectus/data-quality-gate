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

resource "aws_iam_policy" "basic_lambda_policy" {
  name = "${local.resource_name_prefix}-basic-lambda-policy"
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
            "cloudwatch:PutMetricData",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
          ],
          "Resource" : "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
