terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # КРОК 1: закоментуй весь блок backend "s3" нижче і виконай:
  #   terraform init && terraform apply -target=module.s3_backend
  # КРОК 2: розкоментуй блок, встав своє унікальне ім'я bucket і виконай:
  #   terraform init -migrate-state
  backend "s3" {
    # bucket         = "django-cicd-terraform-state-andy-grigs"   # глобально унікальне!
    # key            = "global/terraform.tfstate"
    # region         = "eu-west-1"
    # dynamodb_table = "terraform-locks"
    # encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
