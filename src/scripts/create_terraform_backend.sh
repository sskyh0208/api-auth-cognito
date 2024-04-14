#!/bin/bash

ENV_DIR=/src/terraform/environments/_base

if [ ! -d "$ENV_DIR" ]; then
  echo "Error: Environment directory '$ENV_DIR' does not exist."
  exit 1
fi

# backend.tfファイルのパス
backend_file="$ENV_DIR/backend.tf"

if [ ! -f "$backend_file" ]; then
  echo "Error: Bakend file '$backend_file' does not exist."
  exit 1
fi

# 存在しない場合終了
if [ ! -f "$backend_file" ]; then
    echo "Cloud not found backend.tf file."
    echo "path -> ${backend_file}"
    exit 1
fi

# bucketの値を取得
BUCKET_NAME=$(awk '/bucket/' "$backend_file" | sed 's/.*"\([^"]*\)".*/\1/')

# s3バケット作成
aws s3 mb s3://$BUCKET_NAME