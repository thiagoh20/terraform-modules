locals {
  s3_origin_id = var.s3_bucket_id
}

provider "aws" {
  alias  = "dns"
  region = var.region

}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    origin_id                = local.s3_origin_id
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = var.origin_access_control_id

    connection_attempts = 3
    connection_timeout  = 10
  }
  aliases             = concat([var.domain_name], var.extra_aliases)
  comment             = var.comment
  enabled             = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "cloudfront-logs/${var.domain_name}"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 403
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" // Managed-CachingOptimized
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
  depends_on = [aws_s3_bucket_acl.cloudfront_logs_acl]
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "logs-${var.domain_name}"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_ownership" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs_ownership]

  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"
}

resource "aws_route53_record" "cloudfront_distribution_alias" {
  count    = var.is_apex_domain ? 0 : 1
  provider = aws.dns
  zone_id  = var.hosted_zone_id
  name     = var.domain_name
  type     = "CNAME"
  ttl      = 300
  records  = [aws_cloudfront_distribution.frontend.domain_name]
}

resource "aws_route53_record" "cloudfront_distribution_alias_apex" {
  count           = var.is_apex_domain ? 1 : 0
  provider        = aws.dns
  zone_id         = var.hosted_zone_id
  name            = var.domain_name
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false
  }
}

# Adding count to cloudfront_distribution_alias changes its state address from
# `...alias` to `...alias[0]`. This moved block lets terraform migrate the
# state automatically (avoids destroy+recreate of existing CNAMEs).
moved {
  from = aws_route53_record.cloudfront_distribution_alias
  to   = aws_route53_record.cloudfront_distribution_alias[0]
}
