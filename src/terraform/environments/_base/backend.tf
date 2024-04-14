terraform {
  backend "s3" {
    bucket = "example-auth-cognito-terraform-state"
    region = "ap-northeast-1"
  }
}