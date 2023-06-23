output "step_function_arn" {
  description = "DataQA step function arn"
  value       = aws_sfn_state_machine.fast_data_qa.arn
}

output "lambda_allure_arn" {
  description = "Allure reports generation lambda arn"
  value       = module.lambda_allure_report.lambda_function_arn
}

output "lambda_data_test_arn" {
  description = "Data test generation/running lambda arn"
  value       = module.lambda_data_test.lambda_function_arn
}

output "lambda_report_push_arn" {
  description = "Report push to dynamodb lambda arn"
  value       = module.lambda_push_report.lambda_function_arn
}

output "bucket" {
  description = "Data quality gate bucket with settings and generated tests"
  value       = module.s3_bucket.bucket_name
}
