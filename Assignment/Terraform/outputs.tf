output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.hello_app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.hello_app.arn
}
