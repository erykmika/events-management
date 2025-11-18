output "user_pool_id" {
  value = aws_cognito_user_pool.users.id
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}

output "jwks_url" {
  value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.users.id}/.well-known/jwks.json"
}