resource "aws_s3_bucket" "foundry_storage" {
  bucket = "${var.environment}-${var.project}-foundry-storage"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "foundry_storage" {
  bucket = aws_s3_bucket.foundry_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "foundry_storage" {
  bucket = aws_s3_bucket.foundry_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Just in case someone tries something dirty
resource "aws_s3_bucket_request_payment_configuration" "foundry_storage" {
  bucket = aws_s3_bucket.foundry_storage.bucket
  payer  = "Requester"
}

resource "aws_s3_bucket_cors_configuration" "foundry_storage" {
  bucket = aws_s3_bucket.foundry_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "DELETE"]
    allowed_origins = [local.fqdn]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_policy" "foundry_storage" {
  bucket = aws_s3_bucket.foundry_storage.id
  policy = data.aws_iam_policy_document.foundry_storage.json
}

data "aws_iam_policy_document" "foundry_storage" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.foundry_storage.arn,
      "${aws_s3_bucket.foundry_storage.arn}/*",
    ]
  }
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.foundry_storage.arn}/*"]
  }
}
