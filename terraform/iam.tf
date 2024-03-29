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
            "arn:aws:s3:::${module.s3_bucket.bucket_name}",
            "arn:aws:s3:::${module.s3_bucket.bucket_name}/*",
          ]
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
