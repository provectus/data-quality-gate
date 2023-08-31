resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline_${var.pipeline_name}_${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  tags = {
    Name      = "${var.pipeline_name}_${var.environment}"
    Terraform = true
  }
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  name   = "codepipeline_${var.pipeline_name}_${var.environment}"
  role   = aws_iam_role.codepipeline_role.name
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_iam_role" "docker_build_role" {
  name               = "${var.pipeline_name}_${var.environment}_dockerbuild_role"
  assume_role_policy = data.aws_iam_policy_document.docker_build_assume_role_policy.json

  tags = {
    Name      = "${var.pipeline_name}_${var.environment}_dockerbuild_role"
    Terraform = true
  }
}

resource "aws_iam_role_policy" "docker_build_role_policy" {
  name = "${var.pipeline_name}_${var.environment}_docker_build_role_policy"
  role = aws_iam_role.docker_build_role.name

  policy = data.aws_iam_policy_document.docker_build_policy.json
}

