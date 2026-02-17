# S3 bucket for track downloads (temporary zip storage)
resource "aws_s3_bucket" "downloads" {
  bucket        = "${var.app_name}-downloads"
  force_destroy = true
  tags          = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-downloads" }))
}

# Bucket ownership controls (disable ACLs)
resource "aws_s3_bucket_ownership_controls" "downloads" {
  bucket = aws_s3_bucket.downloads.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "downloads" {
  bucket                  = aws_s3_bucket.downloads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket encryption (KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "downloads" {
  bucket = aws_s3_bucket.downloads.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.web_app.target_key_arn
    }
  }
}

# CORS configuration for presigned URL downloads
resource "aws_s3_bucket_cors_configuration" "downloads" {
  bucket = aws_s3_bucket.downloads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"] # Restrict to your domain in production
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 3600
  }
}

# Lifecycle rule - auto-delete downloads after 24 hours
resource "aws_s3_bucket_lifecycle_configuration" "downloads" {
  bucket = aws_s3_bucket.downloads.id

  rule {
    id     = "expire-downloads-24h"
    status = "Enabled"

    expiration {
      days = 1
    }

    # Also clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
