locals {
  function_name    = "${var.project_name}-${var.env_name}-${var.function_name}"
  archive_key      = "${var.function_name}.zip"
  hash_archive_key = "${local.archive_key}.base64sha256"
  archive_dir      = "${path.module}/tmp"
}

##########################################################
# Lambda function
##########################################################
resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  description      = var.description
  role             = var.role
  architectures    = var.architectures
  runtime          = var.runtime
  handler          = var.handler
  s3_bucket        = var.s3_bucket
  s3_key           = data.aws_s3_bucket_object.archive.key
  source_code_hash = data.aws_s3_bucket_object.hash_archive.body
  memory_size      = var.memory_size
  timeout          = var.timeout
  
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }
  
  environment {
    variables = var.environment
  }

  tags = {
    Name      = local.function_name
    Project   = var.project_name
    Env       = var.env_name
    terraform = "true"
  }

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

##########################################################
# Deploy the Lambda function
##########################################################
resource "null_resource" "deploy_lambda" {
  triggers = {
    "code_diff" = filebase64("${var.function_dir}/${var.handler_file_name}")
  }

  # Create the archive directory
  provisioner "local-exec" {
    command = "mkdir -p ${local.archive_dir} && cp -r ${var.function_dir} ${local.archive_dir}/${var.function_name}"
  }

  # Create the archive
  provisioner "local-exec" {
    command = "cd ${local.archive_dir}/${var.function_name} && zip -r ../${local.archive_key} * && cd $_"
  }

  # Upload the archive to S3
  provisioner "local-exec" {
    command = "aws s3 cp ${local.archive_dir}/${local.archive_key} s3://${var.s3_bucket}/${local.archive_key}"
  }

  # Calculate the hash of the archive
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${local.archive_dir}/${local.archive_key} | openssl enc -base64 | tr d \"\n\" > ${local.archive_dir}/${local.hash_archive_key}"
  }

  # Upload the hash to S3
  provisioner "local-exec" {
    command = "aws s3 cp ${local.archive_dir}/${local.hash_archive_key} s3://${var.s3_bucket}/${local.hash_archive_key}.txt --content-type \"text/plain\""
  }

  # Delete the archive directory
  provisioner "local-exec" {
    command = "rm -rf ${local.archive_dir}"
  }
}

##########################################################
# Data source to get the S3 bucket object
##########################################################
data "aws_s3_bucket_object" "archive" {
  depends_on = [null_resource.deploy_lambda]
  bucket = var.s3_bucket
  key    = local.archive_key
}

data "aws_s3_bucket_object" "hash_archive" {
  depends_on = [null_resource.deploy_lambda]
  bucket = var.s3_bucket
  key    = "${local.hash_archive_key}.txt"
}