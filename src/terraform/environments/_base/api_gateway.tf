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