resource "aws_dynamodb_table" "terraform_locks" {
  name           = "${var.environment}_${var.project}_terraform_locks"
  hash_key       = "LockID"
  read_capacity  = 10
  write_capacity = 10

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.environment}_${var.project}_terraform_locks"
    project     = var.project
    environment = var.environment
    owner       = var.owner
  }
}

resource "aws_s3_bucket" "terraform_states" {
  bucket = "do-not-delete-${var.environment}-${var.project}-terraform-states"

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "DO-NOT-DELETE-${var.environment}-${var.project}-terraform-states"
    project     = var.project
    environment = var.environment
    owner       = var.owner
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_states" {
  bucket = aws_s3_bucket.terraform_states.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_states" {
  bucket = aws_s3_bucket.terraform_states.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_states" {
  bucket = aws_s3_bucket.terraform_states.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}