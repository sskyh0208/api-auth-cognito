resource "aws_iam_role" "cognito_lambda" {
  name = "${local.name_prefix}-cognito-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.custom_cognito_lambda.arn
  ]
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = [ "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "custom_cognito_lambda" {
  name = "${local.name_prefix}-cognito-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-identity:*",
          "cognito-sync:*",
          "cognito-idp:*"
        ]
        Resource = [
          aws_cognito_identity_pool.this.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role" "basic_lambda" {
  name = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}