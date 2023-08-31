resource "aws_ssm_parameter" "github_webhook_secret" {
  name        = "/${var.pipeline_name}/${var.environment}/github/webhook"
  description = "Used by the CICD pipeline to create/destroy github webhooks"
  type        = "SecureString"
  value       = var.github_webhook_token

  tags = {
    Name       = "${var.pipeline_name}_${var.environment}"
    Created_by = "terraform"
  }
}

resource "aws_codepipeline_webhook" "webhook" {
  name           = "${var.pipeline_name}_${var.environment}_TERRAFORM"
  authentication = "GITHUB_HMAC"

  target_action   = "Source"
  target_pipeline = aws_codepipeline.k8s_deployment_pipeline.name

  authentication_configuration {
    secret_token = aws_ssm_parameter.github_webhook_secret.value
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.git_branch}"
  }
}

resource "github_repository_webhook" "webhook" {
  repository = var.git_repo_name

  configuration {
    url          = aws_codepipeline_webhook.webhook.url
    secret       = aws_ssm_parameter.github_webhook_secret.value
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
  active = true
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "cicd-codepipeline-${var.pipeline_name}-${var.environment}"
  acl    = "private"

  tags = {
    Name      = "${var.pipeline_name}_${var.environment}"
    Terraform = true
  }
}

resource "aws_codepipeline" "k8s_deployment_pipeline" {
  name     = "${var.pipeline_name}_${var.environment}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3_kms_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "DownloadSource"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      run_order        = 1
      version          = 1
      output_artifacts = ["SourceCode"]

      configuration = {
        Owner                = var.git_organization
        Repo                 = var.git_repo_name
        Branch               = var.git_branch
        PollForSourceChanges = false
        OAuthToken           = aws_ssm_parameter.github_webhook_secret.value
      }
    }
  }

  stage {
    name = "BuildImage"
    action {
      name     = "buildImage"
      category = "Build"

      configuration = {
        ProjectName = aws_codebuild_project.docker_build.name
      }

      input_artifacts  = ["SourceCode"]
      output_artifacts = []
      owner            = "AWS"
      provider         = "CodeBuild"
      run_order        = 2
      version          = 1
    }
  }
}

