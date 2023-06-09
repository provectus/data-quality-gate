resource "random_uuid" "allure_report" {
  keepers = {
    for filename in setunion(
      fileset("../../functions/allure_report/", "*.py"),
      fileset("../../functions/allure_report/", "requirements.txt"),
      fileset("../../functions/allure_report/", "Dockerfile"),
      fileset("../../functions/allure_report/", "generate_report.sh")
    ) :
    filename => filemd5("../../functions/allure_report/${filename}")
  }
}

resource "random_uuid" "data_test" {
  keepers = {
    for filename in setunion(
      fileset("../../functions/data_test/", "*.py"),
      fileset("../../functions/data_test/", "requirements.txt"),
      fileset("../../functions/data_test/", "Dockerfile")
    ) :
    filename => filemd5("../../functions/data_test/${filename}")
  }
}

resource "random_uuid" "push_report" {
  keepers = {
    for filename in setunion(
      fileset("../../functions/report_push/", "*.py"),
      fileset("../../functions/report_push/", "requirements.txt"),
      fileset("../../functions/report_push/", "Dockerfile")
    ) :
    filename => filemd5("../../functions/report_push/${filename}")
  }
}

module "docker_image_push_report" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = true
  ecr_repo        = "dqg-push-report"
  image_tag       = random_uuid.push_report.result
  source_path     = "../../functions/report_push"
}

module "docker_image_data_test" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = true
  ecr_repo        = "dqg-data-test"
  image_tag       = random_uuid.data_test.result
  source_path     = "../../functions/data_test"
}

module "docker_image_allure_report" {
  source          = "terraform-aws-modules/lambda/aws//modules/docker-build"
  version         = "3.3.1"
  create_ecr_repo = true
  ecr_repo        = "dqg-allure-report"
  image_tag       = random_uuid.allure_report.result
  source_path     = "../../functions/allure_report"
}
