#!/bin/bash

sudo su
wget https://raw.githubusercontent.com/nginxinc/nginx-s3-gateway/2fd4fa4d0b5962c10d615d3dc7c43733ca3eb3b8/standalone_ubuntu_oss_install.sh

export S3_SERVER_PROTO="https"
export S3_BUCKET_NAME="${bucket_name}"
export S3_REGION="${region}"
export S3_STYLE="virtual"
export S3_SERVER="s3-${region}.amazonaws.com"
export S3_SERVER_PORT=443
export AWS_SIGS_VERSION=4
export ALLOW_DIRECTORY_LIST=false
export PROVIDE_INDEX_PAGE=false
export APPEND_SLASH_FOR_POSSIBLE_DIRECTORY=false
export PROXY_CACHE_VALID_OK=1h
export PROXY_CACHE_VALID_NOTFOUND=1m
export PROXY_CACHE_VALID_FORBIDDEN=30s
export CORS_ENABLED=false
export S3_DEBUG=false

bash standalone_ubuntu_oss_install.sh
