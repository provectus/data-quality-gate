data "aws_kms_alias" "s3_kms_key" {
  name = "alias/aws/s3"
}

data "aws_ecr_repository" "k8s_images" {
  name = var.ecr_repository_name
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage"
    ]

    resources = [
      "${data.aws_ecr_repository.k8s_images.arn}*",
    ]
  }
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.artifacts.arn}*",
    ]
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]

    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "docker_build_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "docker_build_policy" {
  statement {
    actions = [
      "ecr:*",
    ]
    resources = [
      data.aws_ecr_repository.k8s_images.arn,
    ]
  }
  statement {
    actions = [
      "logs:*",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.artifacts.arn}*",
    ]
  }
}
