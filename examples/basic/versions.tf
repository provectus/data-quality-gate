terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.8.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.18.0"
    }
  }
}