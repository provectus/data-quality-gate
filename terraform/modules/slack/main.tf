data "aws_iam_policy_document" "slack_qa" {
  policy_id = "__default_policy_ID"
  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive"
    ]
    resources = ["arn:aws:sns:${var.aws_region}:${var.aws_caller_identity}:${var.prefix}-GuardDuty-DataQA"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [var.aws_caller_identity]
    }
  }
}

resource "aws_sns_topic" "data_qa_alerts_notifications" {
  name         = "${var.prefix}-data-qa-notifications"
  display_name = "data-qa-notifications"
  policy       = data.aws_iam_policy_document.slack_qa.json
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 5.3"

  lambda_function_name = "${var.prefix}-notify-slack-data-qa"

  create_sns_topic = false
  sns_topic_name   = var.sns_topic_name

  slack_webhook_url = var.webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username
}