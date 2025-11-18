resource "aws_cognito_user_pool" "users" {
  name = "${var.project}-user-pool"
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = "${var.project}-app-client"
  user_pool_id = aws_cognito_user_pool.users.id
  generate_secret = false
}