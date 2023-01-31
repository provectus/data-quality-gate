# resource "aws_serverlessapplicationrepository_cloudformation_stack" "edge" {
#   //count          = var.cognito_user_pool_id != null ? 1 : 0
#   name           = "cloudfront-edge"
#   application_id = "arn:aws:serverlessrepo:us-east-1:520945424137:applications/cloudfront-authorization-at-edge"
#   capabilities = [
#     "CAPABILITY_IAM",
#     "CAPABILITY_RESOURCE_POLICY",
#   ]
#   parameters = {
#     CreateCloudFrontDistribution = "false"
#     UserPoolArn                  = module.cognito_user_pool[0].arn
#     UserPoolAuthDomain           = "${local.cognito_domain_name}.auth.eu-central-1.amazoncognito.com"
#     UserPoolClientId             = aws_cognito_user_pool_client.user_pool_client[0].id
#     UserPoolClientSecret         = aws_cognito_user_pool_client.user_pool_client[0].client_secret
#     LogLevel                     = "debug"
#     OAuthScopes                  = "email,profile,openid,aws.cognito.signin.user.admin"
#     S3OriginDomainName           = aws_s3_bucket.fast_data_qa.bucket_regional_domain_name
#     EnableSPAMode                = "false"
#   }
# }

