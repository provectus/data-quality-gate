resource "aws_serverlessapplicationrepository_cloudformation_stack" "edge" {
  name           = "cloudfront-edge"
  application_id = "arn:aws:serverlessrepo:us-east-1:520945424137:applications/cloudfront-authorization-at-edge"
  capabilities   = [
    "CAPABILITY_IAM",
    "CAPABILITY_RESOURCE_POLICY",
  ]
  parameters     = {
    CreateCloudFrontDistribution = "false"
    UserPoolArn                  = module.cognito_user_pool.arn
    UserPoolAuthDomain           = "${local.cognito_domain_name}.auth.eu-central-1.amazoncognito.com"
    UserPoolClientId             = aws_cognito_user_pool_client.user_pool_client.id
    UserPoolClientSecret         = aws_cognito_user_pool_client.user_pool_client.client_secret
    LogLevel                     = "debug"
    OAuthScopes                  = "email,profile,openid,aws.cognito.signin.user.admin"
    S3OriginDomainName           = aws_s3_bucket.fast_data_qa.bucket_regional_domain_name
    EnableSPAMode                = "false"
  }
}

#resource "aws_cloudformation_stack" "edge" {
#  name = "cloudfront-edge"
#
#  parameters     = {
#    CreateCloudFrontDistribution = "false"
#    UserPoolArn                  = module.cognito_user_pool.arn
#    UserPoolAuthDomain           = "${local.cognito_domain_name}.auth.eu-central-1.amazoncognito.com"
#    UserPoolClientId             = aws_cognito_user_pool_client.user_pool_client.id
#    UserPoolClientSecret         = aws_cognito_user_pool_client.user_pool_client.client_secret
#    LogLevel                     = "debug"
#    OAuthScopes                  = "email,profile,openid,aws.cognito.signin.user.admin"
#    S3OriginDomainName           = aws_s3_bucket.fast_data_qa.bucket_regional_domain_name
#    EnableSPAMode                = "false"
#  }
#  capabilities = ["CAPABILITY_AUTO_EXPAND", "CAPABILITY_IAM"]
#  template_url = "https://s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.fast_data_qa.bucket}/${aws_s3_object.cloudfront_edge_cf_stack.key}"
#
#}
#
#resource "aws_s3_object" "cloudfront_edge_cf_stack" {
#  bucket = aws_s3_bucket.fast_data_qa.bucket
#  source = "${path.module}/cloudfront_edge/template.yaml"
#  key    = "cloudfromation/cloudfront_edge/template.json"
#  etag   = filemd5("${path.module}/cloudfront_edge/template.yaml")
#}