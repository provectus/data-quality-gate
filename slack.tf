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
    resources = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:${local.resource_name_prefix}-GuardDuty-DataQA"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = ["481193184231", data.aws_caller_identity.current.id]
    }
  }
}

resource "aws_sns_topic" "data_qa_alerts_notifications" {
  name         = "${local.resource_name_prefix}-DataQA-Notifications"
  display_name = "DataQA-Notifications"
  policy       = data.aws_iam_policy_document.slack_qa.json
  tags = merge(
    local.tags,
    {
      "Name" = "aws:sns:topic:GuardDuty:${local.resource_name_prefix}"
    },
  )
}

module "notify_slack" {
  count = var.slack_webhook_url == null ? 0 : 1
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  lambda_function_name = "${local.resource_name_prefix}-notify-slack-data-qa"

  create_sns_topic = false
  sns_topic_name   = aws_sns_topic.data_qa_alerts_notifications.name

  slack_webhook_url = var.slack_webhook_url
  slack_channel     = "dataplatform_alarms_prod_qa"
  slack_username    = "GuardDuty"

  tags = merge(
    local.tags,
    {
      "Name" = "module:notify_slack:${local.resource_name_prefix}"
    },
  )
}

resource "aws_cloudwatch_event_rule" "guardduty_dataqa" {
  description   = "Send message for High and Medium events"
  name          = "${local.resource_name_prefix}-Guardduty-DataQA"
  is_enabled    = "true"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity": [
      4,
      4.0,
      4.1,
      4.2,
      4.3,
      4.4,
      4.5,
      4.6,
      4.7,
      4.8,
      4.9,
      5,
      5.0,
      5.1,
      5.2,
      5.3,
      5.4,
      5.5,
      5.6,
      5.7,
      5.8,
      5.9,
      6,
      6.0,
      6.1,
      6.2,
      6.3,
      6.4,
      6.5,
      6.6,
      6.7,
      6.8,
      6.9,
      7,
      7.0,
      7.1,
      7.2,
      7.3,
      7.4,
      7.5,
      7.6,
      7.7,
      7.8,
      7.9,
      8,
      8.0,
      8.1,
      8.2,
      8.3,
      8.4,
      8.5,
      8.6,
      8.7,
      8.8,
      8.9
    ]
  }
}
PATTERN
  tags = merge(
    local.tags,
    {
      "Name" = "aws:cloudwatch:event:rule:GuardDuty:${local.resource_name_prefix}"
    },
  )
}

resource "aws_cloudwatch_event_target" "guardduty" {
  count = var.slack_webhook_url == null ? 0 : 1
  arn       = aws_sns_topic.data_qa_alerts_notifications.arn
  rule      = aws_cloudwatch_event_rule.guardduty_dataqa.name
  target_id = "guardduty_to_slack_sns_topic"
}