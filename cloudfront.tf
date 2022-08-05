locals {
  cloudfront_origin_name = "${local.resource_name_prefix}-s3-origin"
  aws_waf_web_acl_rule = var.cognito_user_pool_id == null ? [
    {
      action = {
        type = "ALLOW"
      }

      priority = 1
      rule_id  = aws_waf_rule.wafrule[0].id
      type     = "REGULAR"
    }
  ] : []
  aws_cloudfront_distribution = var.cognito_user_pool_id != null ? aws_cloudfront_distribution.s3_distribution_oauth[0].domain_name : var.cloudfront_allowed_subnets != null ? aws_cloudfront_distribution.s3_distribution_ip[0].domain_name : "fake_domain.org"
}

resource "aws_cloudfront_origin_access_identity" "data_qa_oai" {
  comment = local.cloudfront_origin_name
}

resource "aws_cloudfront_origin_access_identity" "never_be_reached" {
  comment = "will-never-be-reached.org"
}

resource "aws_cloudfront_distribution" "s3_distribution_oauth" {
  count = var.cognito_user_pool_id != null ? 1 : 0
  origin {
    domain_name = aws_s3_bucket.fast_data_qa.bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.data_qa_oai.id

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.data_qa_oai.id}"
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
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.data_qa_oai.id

    forwarded_values {
      query_string = true
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

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.CheckAuthHandler
    }
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.HttpHeadersHandler
    }
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.data_qa_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.CheckAuthHandler
    }
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.HttpHeadersHandler
    }
  }

  # Cache behavior with precedence 2
  ordered_cache_behavior {
    path_pattern     = "/parseauth"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dummy-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.ParseAuthHandler
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  # Cache behavior with precedence 3
  ordered_cache_behavior {
    path_pattern     = "/refreshauth"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dummy-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.edge[0].outputs.RefreshAuthHandler
    }
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  # Cache behavior with precedence 4
  ordered_cache_behavior {
    path_pattern     = "/signout"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dummy-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack[0].edge.outputs.SignOutHandler
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
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "TR"]
    }
  }

  tags = var.tags

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #web_acl_id = aws_waf_web_acl.waf_acl.id
}

data "aws_iam_policy_document" "s3_policy_for_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.fast_data_qa.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.data_qa_oai.id}"]
    }
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.fast_data_qa.arn]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.data_qa_oai.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.fast_data_qa.id
  policy = data.aws_iam_policy_document.s3_policy_for_cloudfront.json
}

resource "aws_cloudfront_distribution" "s3_distribution_ip" {
  count = var.cloudfront_allowed_subnets != null ? 1 : 0
  origin {
    domain_name = aws_s3_bucket.fast_data_qa.bucket_regional_domain_name
    origin_id   = local.resource_name_prefix

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.data_qa_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.resource_name_prefix
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.resource_name_prefix

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
    path_pattern     = "/content/immutable/*"
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
    path_pattern     = "/content/*"
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
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "TR"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_waf_web_acl.waf_acl.id
}

resource "aws_waf_ipset" "ipset" {
  count = var.cloudfront_allowed_subnets != null ? 1 : 0
  name  = "tfIPSet"
  dynamic "ip_set_descriptors" {
    for_each = var.cloudfront_allowed_subnets != 0 ? var.cloudfront_allowed_subnets : null
    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }
}

resource "aws_waf_rule" "wafrule" {
  count       = var.cloudfront_allowed_subnets != null ? 1 : 0
  depends_on  = [aws_waf_ipset.ipset[0]]
  name        = "tfWAFRule"
  metric_name = "tfWAFRule"

  predicates {
    data_id = aws_waf_ipset.ipset[0].id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_web_acl" "waf_acl" {

  name        = "tfWebACL"
  metric_name = "tfWebACL"

  default_action {
    type = var.cognito_user_pool_id == null ? "BLOCK" : "ALLOW"
  }

  dynamic "rules" {
    for_each = local.aws_waf_web_acl_rule
    content {
      action {
        type = rules.value["action"]["type"]
      }
      priority = rules.value["priority"]
      rule_id  = rules.value["rule_id"]
      type     = rules.value["type"]
    }
  }
}