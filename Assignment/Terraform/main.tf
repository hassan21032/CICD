resource "aws_ecr_repository" "hello_app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name        = var.ecr_repo_name
    ManagedBy   = "Terraform"
    Environment = "learning"
  }
}