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

#resource "aws_s3_bucket_object" "great_expectations_s3_configs" {
#  for_each = fileset("${path.module}/configs/great_expectations", "**")
#  bucket   = aws_s3_bucket.fast_data_qa.bucket
#  key      = "${aws_s3_bucket.fast_data_qa.bucket}/great_expectations/${each.value}"
#  source   = "${path.module}/configs/great_expectations/${each.value}"
#  etag     = filemd5("${path.module}/configs/great_expectations/${each.value}")
#}

data "template_file" "great_expectations_yml" {
  template = file("${path.module}/templates/great_expectations.yml")
  vars = {
    bucket = aws_s3_bucket.fast_data_qa.bucket
  }
}

resource "aws_s3_object" "great_expectations_yml" {
  bucket       = aws_s3_bucket.fast_data_qa.bucket
  etag         = filemd5("${path.module}/templates/great_expectations.yml")
  content_type = "application/x-yaml"
  content      = templatefile(file("${path.module}/templates/great_expectations.yml"), { bucket = aws_s3_bucket.fast_data_qa.bucket })
  key          = "${aws_s3_bucket.fast_data_qa.bucket}/great_expectations/great_expectations.yml"
}

resource "aws_s3_object" "test_configs" {
  bucket = aws_s3_bucket.fast_data_qa.bucket
  source = "${path.root}/${var.test_coverage_path}"
  key    = "test_configs/test_coverage.json"
  etag   = filemd5("${path.root}/${var.test_coverage_path}")
}

resource "aws_s3_object" "expectations_store" {
  for_each = fileset("${path.root}/${var.expectations_store}", "**")
  bucket   = aws_s3_bucket.fast_data_qa.bucket
  source   = "${path.root}/${var.expectations_store}/${each.value}"
  key      = "${aws_s3_bucket.fast_data_qa.bucket}/great_expectations/expectations/${each.value}"
  etag     = filemd5("${path.root}/${var.expectations_store}/${each.value}")
}

data "template_file" "test_config_manifest" {
  template = file("${path.module}/configs/manifest.json")
  vars = {
    env_name    = var.environment
    bucket_name = aws_s3_bucket.fast_data_qa.bucket
  }
}

resource "aws_s3_object" "test_config_manifest" {
  bucket       = aws_s3_bucket.fast_data_qa.bucket
  etag         = filemd5("${path.module}/configs/manifest.json")
  content_type = "application/json"
  content      = data.template_file.test_config_manifest.rendered
  key          = "test_configs/manifest.json"
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