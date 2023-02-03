output "step_function_arn" {
  value = aws_sfn_state_machine.fast_data_qa.arn
}

output "lambda_allure_arn" {
  value = module.lambda_function_allure_report.arn
}

output "lambda_data_test_arn" {
  value = module.lambda_function_data_test.arn
}

output "lambda_report_push_arn" {
  value = module.lambda_function_push_report.arn
}

output "allure_report_role_arn" {
  value = module.lambda_function_allure_report.lambda_role_arn
}

output "data_test_role_arn" {
  value = module.lambda_function_data_test.lambda_role_arn
}

output "report_push_role_arn" {
  value = module.lambda_function_push_report.lambda_role_arn
}

output "bucket" {
  description = "Data quality gate bucket with settings and generated tests"
  value       = aws_s3_bucket.settings_bucket.bucket
}