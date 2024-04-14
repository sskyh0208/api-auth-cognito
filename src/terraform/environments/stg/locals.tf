locals {
  env_name    = "stg"
  name_prefix = "${var.project_name}-${local.env_name}"

  account_id = data.aws_caller_identity.current.account_id
}