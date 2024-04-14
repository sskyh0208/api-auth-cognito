terraform {
  backend "s3" {
    bucket = "${var.project_name}-auth-cognito-terraform-state"
    region = "${var.region}"
    key    = "stg/terraform.tfstate"
  }
}