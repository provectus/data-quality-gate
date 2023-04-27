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
            "sns:Subscribe",
            "sns:Publish"
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
        },
      ]
      Version = "2012-10-17"
    }
  )
}