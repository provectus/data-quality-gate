resource "aws_ecr_repository" "k8s" {
  name = "k8s-images"

  tags = {
    Project     = "dqg"
    Environment = var.environment
    Terraform   = true
  }
}

resource "random_uuid" "data_test" {
  keepers = {
    for filename in setunion(
      fileset("../../functions/data_test/", "data_test/*.py"),
      fileset("../../functions/data_test/", "requirements.txt"),
      fileset("../../functions/data_test/", "Dockerfile")
    ) :
    filename => filemd5("../../functions/data_test/${filename}")
  }
}

module "docker_image_data_test" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = false
  ecr_repo        = aws_ecr_repository.k8s.name
  image_tag       = random_uuid.data_test.result
  source_path     = "../../functions/data_test"

  build_args = {
    target = "k8s"
  }
}

resource "random_uuid" "allure_report" {
  keepers = {
    for filename in setunion(
      fileset("../../functions/allure_report/", "allure_report/*.py"),
      fileset("../../functions/allure_report/", "requirements.txt"),
      fileset("../../functions/allure_report/", "Dockerfile")
    ) :
    filename => filemd5("../../functions/allure_report/${filename}")
  }
}

module "docker_image_allure_report" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = false
  ecr_repo        = aws_ecr_repository.k8s.name
  image_tag       = random_uuid.allure_report.result
  source_path     = "../../functions/allure_report"

  build_args = {
    target = "k8s"
  }
}
