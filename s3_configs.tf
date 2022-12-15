resource "aws_s3_bucket" "fast_data_qa" {
  bucket_prefix = "${local.resource_name_prefix}-data-quality-gate"
}

resource "aws_s3_bucket_public_access_block" "public_access_block_fast_data_qa" {
  bucket                  = aws_s3_bucket.fast_data_qa.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "fast-data-qa-bucket" {
  bucket = aws_s3_bucket.fast_data_qa.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "great_expectations_yml" {
  bucket       = aws_s3_bucket.fast_data_qa.bucket
  content_type = "application/x-yaml"
  content = templatefile("${path.module}/templates/great_expectations.yml", {
    bucket = aws_s3_bucket.fast_data_qa.bucket
  })
  key = "${aws_s3_bucket.fast_data_qa.bucket}/great_expectations/great_expectations.yml"
  etag = md5(templatefile("${path.module}/templates/great_expectations.yml", {
    bucket = aws_s3_bucket.fast_data_qa.bucket
  }))
}

resource "aws_s3_object" "test_configs" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.module}/${var.test_coverage_path}"
  key    = "test_configs/test_coverage.json"
  etag   = filemd5("${path.module}/${var.test_coverage_path}")
}

resource "aws_s3_object" "pipeline_config" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.module}/${var.pipeline_config_path}"
  key    = "test_configs/pipeline.json"
  etag   = filemd5("${path.module}/${var.pipeline_config_path}")
}

resource "aws_s3_object" "pks_config" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.module}/${var.pks_path}"
  key    = "test_configs/pks.json"
  etag   = filemd5("${path.module}/${var.pks_path}")
}

resource "aws_s3_object" "sort_keys_config" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.module}/${var.sort_keys_path}"
  key    = "test_configs/sort_keys.json"
  etag   = filemd5("${path.module}/${var.sort_keys_path}")
}

resource "aws_s3_object" "mapping_config" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.module}/${var.mapping_path}"
  key    = "test_configs/mapping.json"
  etag   = filemd5("${path.module}/${var.mapping_path}")
}


resource "aws_s3_object" "expectations_store" {
  for_each = fileset("${path.module}/${var.expectations_store}", "**")
  bucket   = aws_s3_bucket.fast_data_qa.bucket
  source   = "${path.module}/${var.expectations_store}/${each.value}"
  key      = "${aws_s3_bucket.fast_data_qa.bucket}/great_expectations/expectations/${each.value}"
  etag     = filemd5("${path.module}/${var.expectations_store}/${each.value}")
}

resource "aws_s3_object" "test_config_manifest" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  etag = md5(templatefile("${path.module}/configs/manifest.json", {
    env_name    = var.environment,
    bucket_name = aws_s3_bucket.fast_data_qa.bucket
  }))
  content_type = "application/json"
  content = templatefile("${path.module}/configs/manifest.json",
    {
      env_name    = var.environment,
      bucket_name = aws_s3_bucket.fast_data_qa.bucket
  })
  key = "test_configs/manifest.json"
}

##Lifecycle policy to delete reports older than 2 weeks
resource "aws_s3_bucket_lifecycle_configuration" "delete_old_reports" {
  bucket = aws_s3_bucket.fast_data_qa.id

  rule {
    expiration {
      days = 14
    }

    filter {
      prefix = "allure/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
    id     = "allure"
  }

  rule {
    expiration {
      days = 14
    }

    filter {
      prefix = "data_docs/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
    id     = "data_docs"
  }

  rule {
    expiration {
      days = 14
    }

    filter {
      prefix = "profiling/"
    }
    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
    id     = "profiling"
  }

  rule {
    expiration {
      days = 14
    }

    filter {
      prefix = "${aws_s3_bucket.fast_data_qa.id}/great_expectations/uncommitted/"
    }
    noncurrent_version_expiration {
      noncurrent_days = 14
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
    id     = "great_expectations_uncommitted"
  }
}