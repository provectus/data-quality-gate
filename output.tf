output "qa_step_functions_arn" {
  value = aws_sfn_state_machine.fast_data_qa.arn
}

output "cloudfront_domain" {
  value = local.aws_cloudfront_distribution
}