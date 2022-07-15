terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.18.0"
    }
  }
  required_version = ">= 1.1.7"
}
