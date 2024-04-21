module "cognito_login" {
  depends_on = [ aws_dynamodb_table.db_users ]
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
  depends_on = [ aws_dynamodb_table.db_users ]
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
  depends_on = [ aws_dynamodb_table.db_users ]
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
  depends_on = [ aws_dynamodb_table.db_users ]
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

module "cognito_post_confirmation" {
  depends_on = [ aws_dynamodb_table.db_users ]
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-post-confirmation"
  description       = "Lambda function to handle post confirmation with Cognito"
  role              = aws_iam_role.basic_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/post_confirmation"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.db_users.name
    DYNAMODB_TABLE_PK   = local.users_table_pk
    DYNAMODB_TABLE_SK   = local.users_table_sk
  }
}

module "cognito_signout" {
  depends_on = [ aws_dynamodb_table.db_users ]
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "cognito-signout"
  description       = "Lambda function to sign out with Cognito"
  role              = aws_iam_role.cognito_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/auth/cognito/signout"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment   = {
    COGNITO_CLIENT_ID     = aws_cognito_user_pool_client.this.id
    COGNITO_CLIENT_SECRET = aws_cognito_user_pool_client.this.client_secret
  }
}

module "user_get" {
  depends_on = [ aws_dynamodb_table.db_users ]
  source = "../../modules/lambda"

  project_name      = var.project_name
  env_name          = local.env_name
  function_name     = "user-get"
  description       = "Lambda function to get user details"
  role              = aws_iam_role.basic_lambda.arn
  s3_bucket         = aws_s3_bucket.this.bucket
  runtime           = "nodejs20.x"
  function_dir      = "../../../lambda/user/get"
  handler_file_name = "index.mjs"
  handler           = "index.handler"
  
  environment = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.db_users.name
    DYNAMODB_TABLE_PK   = local.users_table_pk
    DYNAMODB_TABLE_SK   = local.users_table_sk
  }
}