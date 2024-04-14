resource "aws_s3_bucket" "this" {
  bucket = "${local.name_prefix}-lambda-source"
  
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-lambda-source"
  }
}