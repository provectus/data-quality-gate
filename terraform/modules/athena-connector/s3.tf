resource "aws_s3_bucket" "athena_spill_bucket" {
  bucket = "${var.data_catalog_name}-athena"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.athena_spill_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "athena_spill_bucket" {
  bucket = aws_s3_bucket.athena_spill_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
