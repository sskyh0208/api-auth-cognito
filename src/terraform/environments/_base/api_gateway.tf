resource "aws_api_gateway_rest_api" "this" {
  name        = "${local.name_prefix}-api-gateway-auth-cognito"
  description = "API Gateway for ${local.name_prefix}"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(jsonencode({
      api_id = aws_api_gateway_rest_api.this.id
    }))
  }
}

resource "aws_api_gateway_model" "emptyModel" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  name = "Empty"
  description = "This is a default empty schema mode"
  content_type = "application/json"

  schema = jsonencode({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Empty Schema",
    "type": "object"
  })
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "${local.name_prefix}-cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  type                   = "COGNITO_USER_POOLS"
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [aws_cognito_user_pool.this.arn]
}

######################################################################
# Path: /login
# Method: POST
######################################################################
resource "aws_api_gateway_resource" "login" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "login"
}

resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.cognito_login.invoke_arn
}

resource "aws_api_gateway_method_response" "login_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "login_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.login.id
  http_method = aws_api_gateway_method.login_post.http_method
  status_code = aws_api_gateway_method_response.login_post_200.status_code
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "login_post" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_login.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/login"
}

######################################################################
# Path: /signup
# Method: POST
######################################################################
resource "aws_api_gateway_resource" "signup" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "signup"
}

resource "aws_api_gateway_method" "signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "signup_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signup.id
  http_method = aws_api_gateway_method.signup_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.cognito_signup.invoke_arn
}

resource "aws_api_gateway_method_response" "signup_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signup.id
  http_method = aws_api_gateway_method.signup_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "signup_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signup.id
  http_method = aws_api_gateway_method.signup_post.http_method
  status_code = aws_api_gateway_method_response.signup_post_200.status_code
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "signup_post" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_signup.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/signup"
}

######################################################################
# Path: /confirm-signup
# Method: POST
######################################################################
resource "aws_api_gateway_resource" "confirm_signup" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "confirm-signup"
}

resource "aws_api_gateway_method" "confirm_signup_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.confirm_signup.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "confirm_signup_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.confirm_signup.id
  http_method = aws_api_gateway_method.confirm_signup_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.cognito_confirm_signup.invoke_arn
}

resource "aws_api_gateway_method_response" "confirm_signup_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.confirm_signup.id
  http_method = aws_api_gateway_method.confirm_signup_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "confirm_signup_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.confirm_signup.id
  http_method = aws_api_gateway_method.confirm_signup_post.http_method
  status_code = aws_api_gateway_method_response.confirm_signup_post_200.status_code
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "confirm_signup_post" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_confirm_signup.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/confirm-signup"
}

######################################################################
# Path: /signout
# Method: POST
######################################################################
resource "aws_api_gateway_resource" "signout" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "signout"
}

resource "aws_api_gateway_method" "signout_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.signout.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "signout_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signout.id
  http_method = aws_api_gateway_method.signout_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.cognito_signout.invoke_arn
}

resource "aws_api_gateway_method_response" "signout_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signout.id
  http_method = aws_api_gateway_method.signout_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "signout_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.signout.id
  http_method = aws_api_gateway_method.signout_post.http_method
  status_code = aws_api_gateway_method_response.signout_post_200.status_code
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "signout_post" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_signout.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/signout"
}

######################################################################
# Path: /user
# Method: GET
######################################################################
resource "aws_api_gateway_resource" "user" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "user"
}

resource "aws_api_gateway_method" "user_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.user.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id

  request_parameters = {
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "user_get_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.user_get.invoke_arn
}

resource "aws_api_gateway_method_response" "user_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "user_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.user.id
  http_method = aws_api_gateway_method.user_get.http_method
  status_code = aws_api_gateway_method_response.user_get_200.status_code
  response_templates = {
    "application/json" = ""
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_lambda_permission" "user_get" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.user_get.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/GET/user"
}