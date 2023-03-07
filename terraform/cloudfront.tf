resource "aws_cloudfront_origin_access_identity" "data_qa_oai" {
  comment = "${local.resource_name_prefix}-s3-origin"
}

resource "aws_cloudfront_origin_access_identity" "never_be_reached" {
  comment = "will-never-be-reached.org"
}

data "aws_iam_policy_document" "s3_policy_for_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.settings_bucket.arn}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.data_qa_oai.id}"
      ]
    }
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.settings_bucket.arn]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.data_qa_oai.id}"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.settings_bucket.id
  policy = data.aws_iam_policy_document.s3_policy_for_cloudfront.json
}

resource "aws_cloudfront_distribution" "s3_distribution_ip" {
  origin {
    domain_name = aws_s3_bucket.settings_bucket.bucket_regional_domain_name
    origin_id   = local.resource_name_prefix

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.data_qa_oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = "will-never-be-reached.org"
    origin_id   = "dummy-origin"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.resource_name_prefix
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dummy-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/profiling/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.resource_name_prefix

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/allure/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.resource_name_prefix

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 2
  ordered_cache_behavior {
    path_pattern     = "/data_docs/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.resource_name_prefix

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.waf_acl.arn
}

resource "aws_wafv2_ip_set" "vpn_ipset" {
  name               = "${local.resource_name_prefix}-ip-set"
  description        = "VPN IP set"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = var.cloudfront_allowed_subnets
}

resource "aws_wafv2_web_acl" "waf_acl" {
  name  = "${local.resource_name_prefix}-web-acl"
  scope = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "tfWAFVpnRule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.vpn_ipset.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${local.cloudwatch_prefix}WafVpnIPRule"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${local.cloudwatch_prefix}WafAcl"
    sampled_requests_enabled   = false
  }
}
