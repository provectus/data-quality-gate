resource "aws_sns_topic" "notifications" {
  count = var.create_cloudwatch_notifications_topic ? 1 : 0

  name         = "${local.resource_name_prefix}-DataQA-Notifications"
  display_name = "DataQA-Notifications"
}

resource "aws_sns_topic_policy" "notification" {
  count = var.create_cloudwatch_notifications_topic ? 1 : 0

  arn    = aws_sns_topic.notifications[0].arn
  policy = data.aws_iam_policy_document.slack_notification_sns[0].json
}

data "aws_iam_policy_document" "slack_notification_sns" {
  count = var.create_cloudwatch_notifications_topic ? 1 : 0

  policy_id = "${local.resource_name_prefix}-notification-sns"

  statement {
    sid = "SlackNotificationSNS"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.notifications[0].arn,
    ]
  }
}