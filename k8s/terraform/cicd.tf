#module "cicd" {
#  source = "./modules/cicd"
#
#  pipeline_name = "eks-sample"
#  environment   = "dev"
#
#  git_branch           = "k8s"
#  git_organization     = "provectus"
#  git_repo_name        = "data-quality-gate"
#  github_webhook_token = var.github_access_token
#
#  ecr_repository_name = aws_ecr_repository.k8s.name
#}
