resource "aws_cognito_user_pool" "users" {
  name = "${var.project}-user-pool"
}

resource "aws_cognito_user_pool_client" "app_client" {
  name            = "${var.project}-app-client"
  user_pool_id    = aws_cognito_user_pool.users.id
  generate_secret = false
}


resource "aws_cognito_user" "default_user" {
  user_pool_id = aws_cognito_user_pool.users.id
  username     = "defaultuser"
  
  attributes = {
    email         = "defaultuser@example.com"
    email_verified = "true"   # mark email as confirmed
  }

  temporary_password = var.default_user_password
  message_action     = "SUPPRESS" # do not send welcome email
}

resource "null_resource" "confirm_default_user" {
  depends_on = [aws_cognito_user.default_user]

  provisioner "local-exec" {
    command = <<EOT
  aws cognito-idp admin-set-user-password \
  --user-pool-id ${aws_cognito_user_pool.users.id} \
  --username defaultuser \
  --password ${var.default_user_password}' \
  --permanent
  EOT
  }
}
