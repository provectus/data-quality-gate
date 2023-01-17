output "qa_step_functions_arn" {
  value = aws_sfn_state_machine.fast_data_qa.arn
}

output "cloudfront_domain" {
  value = local.aws_cloudfront_distribution
}

output "allure_report_role_arn" {
  value = module.lambda_function_allure_report.lambda_role_arn
}

output "fast_data_role_arn" {
  value = module.lambda_function_fast_data.lambda_role_arn
}

output "push_report_role_arn" {
  value = module.lambda_function_push_report.lambda_role_arn
}

output "s3_fast_data_qa" {
  value = aws_s3_bucket.settings_bucket.bucket
}