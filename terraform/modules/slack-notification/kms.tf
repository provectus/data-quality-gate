resource "aws_kms_alias" "slack_notification" {
  name          = "alias/${var.stack_prefix}-slack-notification"
  target_key_id = aws_kms_key.slack_notification.key_id
}

resource "aws_kms_key" "slack_notification" {
  description         = "This key is used to encrypt/decrypt configuration parameters for slack notifications"
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.slack_notification.json

  tags = merge(
    local.tags,
    {
      "Name" = "${var.stack_prefix}-slack-notification"
    },
    {
      "${var.stack_prefix}" = var.stack_prefix
    },
  )

  depends_on = [data.aws_iam_policy_document.slack_notification]

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "slack_notification" {
  policy_id = "${var.stack_prefix}-slack-notification"
  version   = "2012-10-17"

  statement {
    sid = "Enable IAM Permissions"

    actions = ["kms:*"]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }

  statement {
    sid = "Breakglass role"

    actions = [
      "kms:*",
    ]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/OAdministrator"
      ]
    }
  }

  statement {
    sid = "Jenkins role"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        var.jenkins_role_arn
      ]
    }
  }

  statement {
    sid = "Diagnosis role"

    actions = [
      "kms:Describe*",
      "kms:List*",
      "kms:Get*",
    ]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = toset([
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/access-analyzer.amazonaws.com/AWSServiceRoleForAccessAnalyzer",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CloudConformity",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/OReadOnly",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/OSecurityEngineer",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/OSecurityOpsAnalyst",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/OSiteReliabilityEngineer",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LuminDigitalSecurity/SiteReliabilityEngineering",
      ])
    }
  }

  statement {
    sid    = "PermitIAMAccessAnalyzer"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["access-analyzer.amazonaws.com"]
    }

    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListGrants",
      "kms:ListKeyPolicies",
    ]

    resources = ["*"] # Must be *
  }

  statement {
    sid = "Allow Lambda to use the key"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.slack_notification.arn
      ]
    }
  }

  statement {
    sid = "Allow Macie to use the key"

    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSMacieServiceCustomerServiceRole/AmazonMacieSession"
      ]
    }
  }
}
