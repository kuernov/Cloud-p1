output "backend_ecr_repo" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repo" {
  value = aws_ecr_repository.frontend.repository_url
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "s3_bucket" {
  value = aws_s3_bucket.media.bucket
}

output "alb_dns_name" {
  description = "Publiczny adres URL aplikacji (ALB)"
  value       = module.alb.dns_name
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "cognito_app_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}
