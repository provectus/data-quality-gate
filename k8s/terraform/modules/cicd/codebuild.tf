resource "aws_codebuild_project" "docker_build" {
  name           = "${var.pipeline_name}_${var.environment}_DockerBuild"
  build_timeout  = var.docker_build_timeout
  service_role   = aws_iam_role.docker_build_role.arn
  encryption_key = data.aws_kms_alias.s3_kms_key.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    location = "${aws_s3_bucket.artifacts.bucket}/${var.pipeline_name}/${var.environment}"
    type     = "S3"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.docker_build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type                = "GITHUB"
    location            = "https://github.com/${var.git_organization}/${var.git_repo_name}/tree/${var.git_branch}"
    buildspec           = "./k8s/terraform/buildspecs/buildspec-docker.yml"
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false
  }

  tags = {
    Name      = "${var.pipeline_name}_${var.environment}_docker_build"
    Terraform = true
  }
}
