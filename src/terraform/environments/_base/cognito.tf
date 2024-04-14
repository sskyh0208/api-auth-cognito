locals {
  cognito_domain = "mpec39"
}

resource "aws_cognito_user_pool" "this" {
  name = "${local.name_prefix}-cognito-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = false

    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}."
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_CODE"
    email_message         = "Your verification code is {####}."
    email_subject         = "Your verification code"
    email_message_by_link = "Your verification link is {##Verify Email##}."
    email_subject_by_link = "Your verification link"
    sms_message           = "Your verification code is {####}."
  }

  lambda_config {
    custom_message = module.cognito_custom_message.arn
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name = "${local.name_prefix}-cognito-user-pool-client"

  user_pool_id = aws_cognito_user_pool.this.id
  
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  callback_urls                        = ["http://localhost:3000"]
  logout_urls                          = []
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
  prevent_user_existence_errors        = "ENABLED"
  generate_secret                      = true
  refresh_token_validity               = 30
}

resource "aws_cognito_identity_pool" "this" {
  identity_pool_name = "${local.name_prefix}-cognito-identity-pool"

  allow_unauthenticated_identities = false
  openid_connect_provider_arns     = []
  saml_provider_arns               = []
  supported_login_providers        = {}

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.this.id
    provider_name           = aws_cognito_user_pool.this.endpoint
    server_side_token_check = false
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain = local.cognito_domain
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_lambda_permission" "custom_message" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_custom_message.arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}