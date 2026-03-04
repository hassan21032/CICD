terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "hassan21032-terraform-state"
    key    = "cicd/ecr/terraform.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}