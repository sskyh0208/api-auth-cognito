variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "env_name" {
  description = "The name of the environment"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "description" {
  description = "The description of the Lambda function"
  type        = string
}

variable "role" {
  description = "The ARN of the IAM role that the Lambda function assumes when it executes"
  type        = string
}

variable "architectures" {
  description = "The architectures supported by the Lambda function"
  type        = list(string)
  default     = ["arm64"]
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "handler" {
  description = "The entry point for the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "The S3 bucket that contains the Lambda function package"
  type        = string
}

variable "memory_size" {
  description = "The amount of memory that the Lambda function has access to"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The amount of time that the Lambda function has to run in seconds"
  type        = number
  default     = 10
}

variable "ephemeral_storage_size" {
  description = "The size of the ephemeral storage in MiB"
  type        = number
  default     = 512
}

variable "environment" {
  description = "The environment variables that are available to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "function_dir" {
  description = "The path to the Lambda function code in local filesystem"
  type        = string
}

variable "handler_file_name" {
  description = "The name of the Lambda function handler file"
  type        = string
}