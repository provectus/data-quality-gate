locals {
  lambda_ecr_repository_policy = <<LAMBDA_POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "LambdaECRImageRetrievalPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:DeleteRepositoryPolicy",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:SetRepositoryPolicy"
      ],
      "Condition": {
        "StringLike": {
          "aws:sourceArn": "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:*"
        }
      }
    }
  ]
}
LAMBDA_POLICY
}

resource "aws_ecr_repository" "fast_data_qa" {
  name                 = "${local.resource_name_prefix}-fast-data-qa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "allure_report" {
  name                 = "${local.resource_name_prefix}-allure-report"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "push_report" {
  name                 = "${local.resource_name_prefix}-push-report"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

# lambdas
resource "aws_ecr_repository_policy" "lambda-fast-data-qa-policy" {
  repository = aws_ecr_repository.fast_data_qa.name
  policy     = local.lambda_ecr_repository_policy
}

resource "aws_ecr_repository_policy" "lambda-allure-report-policy" {
  repository = aws_ecr_repository.allure_report.name
  policy     = local.lambda_ecr_repository_policy
}

resource "aws_ecr_repository_policy" "lambda-push-report-policy" {
  repository = aws_ecr_repository.push_report.name
  policy     = local.lambda_ecr_repository_policy
}
