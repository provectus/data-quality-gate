variable "pipeline_name" {
  description = "Name of deployment codepipeline"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of ecr repository to store k8s images"
  type        = string
}

variable "git_branch" {
  description = "Name of git branch to run pipeline"
  type        = string
}

variable "git_organization" {
  description = "GitHub oraganisation name"
  type        = string
}

variable "git_repo_name" {
  description = "Name of github repository"
  type        = string
}

variable "github_webhook_token" {
  description = "Github webhook token"
  type        = string
  sensitive   = true
}

variable "docker_build_image" {
  description = "Name of the image that will be used to in the pipeline build stage."
  type        = string
  default     = "aws/codebuild/docker:18.09.0"
}

variable "docker_build_timeout" {
  description = "Timeout in minutes of the docker build."
  type        = string
  default     = 5
}
