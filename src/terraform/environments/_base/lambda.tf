module "cognito_login" {
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-login"
  description       = "Lambda function to authenticate with Cognito"
  role              = aws_iam_role.cognito_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/login"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment   = {
    COGNITO_CLIENT_ID     = aws_cognito_user_pool_client.this.id
    COGNITO_CLIENT_SECRET = aws_cognito_user_pool_client.this.client_secret
  }
}

module "cognito_signup" {
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-signup"
  description       = "Lambda function to sign up with Cognito"
  role              = aws_iam_role.cognito_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/signup"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment   = {
    COGNITO_CLIENT_ID     = aws_cognito_user_pool_client.this.id
    COGNITO_CLIENT_SECRET = aws_cognito_user_pool_client.this.client_secret
  }
}

module "cognito_confirm_signup" {
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-confirm-signup"
  description       = "Lambda function to confirm sign up with Cognito"
  role              = aws_iam_role.cognito_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/confirm_signup"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment   = {
    COGNITO_CLIENT_ID     = aws_cognito_user_pool_client.this.id
    COGNITO_CLIENT_SECRET = aws_cognito_user_pool_client.this.client_secret
  }
}

module "cognito_custom_message" {
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-custom-message"
  description       = "Lambda function to customize Cognito messages"
  role              = aws_iam_role.basic_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/custom_message"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
}