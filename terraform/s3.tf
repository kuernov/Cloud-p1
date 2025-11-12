resource "random_id" "bucket_id" {
  byte_length = 4
}

# Główny bucket
resource "aws_s3_bucket" "media" {
  bucket = "${var.project}-media-${var.env}-${random_id.bucket_id.hex}"

  tags = {
    Name        = "${var.project}-media"
    Environment = var.env
  }

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "media_versioning" {
  bucket = aws_s3_bucket.media.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "media_ownership" {
  bucket = aws_s3_bucket.media.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "media_public_access" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "media_lifecycle" {
  bucket = aws_s3_bucket.media.id

  rule {
    id     = "expire-media"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}

# data "aws_iam_policy_document" "s3_media_access" {
#   statement {
#     sid = "AllowMediaBucketAccess"
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.media.arn}/*" # Dostęp do OBIEKTÓW w buckecie
#     ]
#   }
#   statement {
#     sid = "AllowBucketListing"
#     actions = [
#       "s3:ListBucket"
#     ]
#     resources = [
#       aws_s3_bucket.media.arn # Dostęp do samego BUCKETA
#     ]
#   }
# }

# # 2. Stworzenie zasobu Polityki IAM z tego JSONa
# resource "aws_iam_policy" "s3_media_policy" {
#   name   = "${var.project}-s3-media-access-policy-${var.env}"
#   policy = data.aws_iam_policy_document.s3_media_access.json
# }