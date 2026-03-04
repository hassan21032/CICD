variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "hello-app"
}