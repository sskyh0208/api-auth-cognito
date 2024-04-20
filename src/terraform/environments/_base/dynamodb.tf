locals {
  users_table_pk = "PK"
  users_table_sk = "SK"
}

resource "aws_dynamodb_table" "db_users" {
  name           = "${local.name_prefix}-db-users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = local.users_table_pk
  range_key      = local.users_table_sk
  attribute {
    name = local.users_table_pk
    type = "S"
  }
  attribute {
    name = local.users_table_sk
    type = "S"
  }
  
  tags = {
    Name = "${local.name_prefix}-db-users"
  }
}