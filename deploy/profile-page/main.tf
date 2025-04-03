locals {
  bucket_name      = "${var.account_id}-${var.domain}"
  logs_bucket_name = "${var.account_id}-logs"
  tags = {
    Client          = var.client
    Contact         = var.contact
    Domain          = var.domain
    Domain-Provider = var.domain_provider
    Email           = var.email
    Managed-by      = "Terraform"
  }
}

# We should have a logs bucket only accessible by the root account

resource "aws_s3_bucket" "bucket-logs" {
  bucket        = local.logs_bucket_name
  force_destroy = true

  tags = local.tags
}

# Logs bucket should have versioning enabled

resource "aws_s3_bucket_versioning" "bucket-logs-versioning" {
  bucket = aws_s3_bucket.bucket-logs.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Logs bucket should have a policy that allows only the root account to access it
# Logs bucket should have a policy that allows only CloudFront to write logs to it

data "aws_iam_policy_document" "policy-document-logs" {
  statement {
    sid    = "AllowRootAccess"
    effect = "Allow"
    resources = [
      aws_s3_bucket.bucket-logs.arn,
      "${aws_s3_bucket.bucket-logs.arn}/*",
    ]

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowCloudFrontAccess"
    effect = "Allow"
    resources = [
      aws_s3_bucket.bucket-logs.arn,
      "${aws_s3_bucket.bucket-logs.arn}/*",
    ]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-logs-policy" {
  bucket = aws_s3_bucket.bucket-logs.bucket
  policy = data.aws_iam_policy_document.policy-document-logs.json
}

# Enable ACL access for the logs bucket
# LINK: https://stackoverflow.com/questions/71080354/getting-the-bucket-does-not-allow-acls-error

resource "aws_s3_bucket_ownership_controls" "bucket-logs-ownership-controls" {
  bucket = aws_s3_bucket.bucket-logs.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket-logs-acl" {
  bucket = aws_s3_bucket.bucket-logs.bucket

  access_control_policy {
    owner {
      id = data.aws_canonical_user_id.canonical_user_id.id
    }

    grant {
      # LINK: https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#permissions
      permission = "FULL_CONTROL"

      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/s3/LogDelivery"
      }
    }
  }

  depends_on = [
    aws_s3_bucket_ownership_controls.bucket-logs-ownership-controls,
  ]
}

# Create a lifecycle rule for the logs bucket to delete logs older than 07 days

resource "aws_s3_bucket_lifecycle_configuration" "bucket-logs-lifecycle" {
  bucket = aws_s3_bucket.bucket-logs.bucket

  rule {
    id     = "DeleteLogsOlderThan07Days"
    status = "Enabled"

    expiration {
      days = 7
    }

    transition {
      days          = 1
      storage_class = "GLACIER"
    }
  }
}

# Each client has its own bucket and the bucket name is the client name

resource "aws_s3_bucket" "bucket" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = local.tags
}

# When acessing the website root, the user should be redirected to the client-a/index.html file

resource "aws_s3_bucket_website_configuration" "bucket-website-configuration" {
  bucket = aws_s3_bucket.bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload everything from /clients/{var.domain} and /generic to the bucket
# LINK: https://pairingwith.me/david/articles/2024/01/29/using-terraform-for-uploading-files-to-an-s3-bucket

resource "aws_s3_object" "object-client" {
  for_each = fileset("clients/${var.domain}", "**/*.*")

  bucket = aws_s3_bucket.bucket.bucket
  key    = replace(each.key, "clients/${var.domain}/", "")
  source = "clients/${var.domain}/${each.key}"
  etag   = filemd5("clients/${var.domain}/${each.key}")
  content_type = lookup({
    ".html" : "text/html",
    ".md" : "text/markdown",
    ".xml" : "application/xml",
    ".json" : "application/json",
    ".txt" : "text/plain",
    ".csv" : "text/csv",
    ".css" : "text/css",
    ".pdf" : "image/pdf",
    ".png" : "image/png",
    ".jpg" : "image/jpeg",
    ".jpeg" : "image/jpeg",
    ".js" : "text/javascript",
    ".mjs" : "text/javascript"
  }, regex("\\.[^.]+$", each.value), null)

  tags = local.tags
}

resource "aws_s3_object" "object-generic" {
  for_each = fileset("generic", "**/*.*")

  bucket = aws_s3_bucket.bucket.bucket
  key    = replace(each.key, "generic/", "")
  source = "generic/${each.key}"
  etag   = filemd5("generic/${each.key}")
  content_type = lookup({
    ".html" : "text/html",
    ".md" : "text/markdown",
    ".xml" : "application/xml",
    ".json" : "application/json",
    ".txt" : "text/plain",
    ".csv" : "text/csv",
    ".css" : "text/css",
    ".pdf" : "image/pdf",
    ".png" : "image/png",
    ".jpg" : "image/jpeg",
    ".jpeg" : "image/jpeg",
    ".js" : "text/javascript",
    ".mjs" : "text/javascript"
  }, regex("\\.[^.]+$", each.value), null)

  tags = local.tags
}

# Create sitemap.xml and robots.txt from template/sitemap.tpl and template/robots.tpl

data "template_file" "sitemap" {
  template = file("template/sitemap.tpl")

  vars = {
    domain = var.domain
  }
}

data "template_file" "robots" {
  template = file("template/robots.tpl")

  vars = {
    domain = var.domain
  }
}

resource "aws_s3_object" "object-sitemap" {
  bucket       = aws_s3_bucket.bucket.bucket
  key          = "sitemap.xml"
  content      = data.template_file.sitemap.rendered
  etag         = filemd5("template/sitemap.tpl")
  content_type = "application/xml"

  tags = local.tags
}

resource "aws_s3_object" "object-robots" {
  bucket       = aws_s3_bucket.bucket.bucket
  key          = "robots.txt"
  content      = data.template_file.robots.rendered
  etag         = filemd5("template/robots.tpl")
  content_type = "text/plain"

  tags = local.tags
}

# The bucket should be public

resource "aws_s3_bucket_ownership_controls" "bucket-ownership-controls" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access-block" {
  bucket = aws_s3_bucket.bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.bucket
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.bucket-ownership-controls,
    aws_s3_bucket_public_access_block.bucket-public-access-block,
  ]
}

# The bucket should have a policy that allows public read access

data "aws_iam_policy_document" "policy-document" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    actions = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  depends_on = [
    aws_s3_bucket_public_access_block.bucket-public-access-block,
  ]
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.policy-document.json
}

# The bucket should have versioning enabled

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Distribute using CloudFront

resource "aws_cloudfront_distribution" "distribution" {
  count = var.acm_certificate_is_issued ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.bucket
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for ${aws_s3_bucket.bucket.bucket}"
  default_root_object = "index.html"

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
    error_caching_min_ttl = 5
  }

  logging_config {
    bucket          = aws_s3_bucket.bucket-logs.bucket_regional_domain_name
    include_cookies = false
    prefix          = "${var.domain}/"
  }

  aliases = [
    var.domain,
    "www.${var.domain}",
  ]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.bucket.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # LINK: https://aws.amazon.com/cloudfront/pricing/?nc1=h_ls
  price_class = var.enable_faster_deliver_content ? "PriceClass_All" : "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = length(var.restriction_locations) > 0 ? "whitelist" : "none"
      locations        = length(var.restriction_locations) > 0 ? var.restriction_locations : null
    }
  }

  # LINK: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html#alternate-domain-names-requirements
  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    # LINK: https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_ViewerCertificate.html
    ssl_support_method = "sni-only"
  }

  depends_on = [
    aws_s3_bucket_acl.bucket-logs-acl,
  ]

  tags = local.tags
}
