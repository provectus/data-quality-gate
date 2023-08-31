data "aws_s3_bucket" "settings_bucket" {
  bucket = "dqg-settings-dev"
}

resource "aws_iam_policy" "s3_read" {
  name = "dqg-k8s-s3_read"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : [
          data.aws_s3_bucket.settings_bucket.arn,
          "${data.aws_s3_bucket.settings_bucket.arn}/*"
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
          "athena:GetWorkGroup",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ],
        "Resource" : "arn:aws:athena:*:${data.aws_caller_identity.current.account_id}:workgroup/primary"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : "arn:aws:s3:::aws-athena-query-results-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "athena:ListWorkGroups",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : "arn:aws:s3:::aws-athena-query-results-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
      }
    ]
  })
}

resource "aws_iam_role" "s3_read" {
  name = "dqg-k8s-s3_read"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : module.eks.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:default:dqg-s3-read",
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_attachment" {
  role       = aws_iam_role.s3_read.name
  policy_arn = aws_iam_policy.s3_read.arn
}
