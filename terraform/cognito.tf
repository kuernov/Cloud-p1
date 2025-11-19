########################################
# 1. User Pool
########################################
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.project}-user-pool-${var.env}"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  mfa_configuration = "OFF"

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  tags = {
    Name = "${var.project}-user-pool-${var.env}"
  }
}

########################################
# 2. User Pool Client (dla Angular)
########################################
resource "aws_cognito_user_pool_client" "app_client" {
  name         = "${var.project}-client-${var.env}"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  # NIE używamy Hosted UI ani OAuth2 Authorization Code
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

  # Refresh tokeny
  refresh_token_validity = 30
  access_token_validity  = 60
  id_token_validity      = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}
