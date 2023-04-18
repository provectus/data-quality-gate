locals {
  cognito_domain_name = "${local.resource_name_prefix}-user-pool"
}

module "cognito_user_pool" {
  count          = var.cognito_user_pool_id != null ? 1 : 0
  source         = "lgallard/cognito-user-pool/aws"
  user_pool_name = "${local.resource_name_prefix}-user-pool"
  enabled        = var.cognito_user_pool_id == null ? true : false
  tags           = var.tags
  domain         = local.cognito_domain_name
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  count           = var.cognito_user_pool_id != null ? 1 : 0
  name            = "Lambda Edge authorizer"
  generate_secret = true
  user_pool_id    = var.cognito_user_pool_id != null ? var.cognito_user_pool_id : module.cognito_user_pool[0].id
  # Not sure how to set it, because cloudfront distribution settings depends from cognito_user_pool_client and vise versa
  callback_urls = [
    "https://call-back-url-here-cloudfront/parseauth"
  ]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true
  explicit_auth_flows                  = []
  supported_identity_providers         = ["COGNITO"]
}
