resource "aws_iam_role" "slack_notification" {
  name = local.lambda_function_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = local.tags
}

resource "aws_iam_role_policy" "slack_notification" {
  name = local.lambda_function_name
  role = aws_iam_role.slack_notification.id

  policy = data.aws_iam_policy_document.slack_notification_lambda.json
}

data "aws_iam_policy_document" "slack_notification_lambda" {
  version = "2012-10-17"

  statement {
    sid    = "VpcAccess"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.slack_notification.arn}:*",
    ]
  }

  statement {
    sid    = "ModifyCloudWatch"
    effect = "Allow"

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:TagResource",
      "cloudwatch:PutMetricAlarm"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "slack_notification" {
  role       = aws_iam_role.slack_notification.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
