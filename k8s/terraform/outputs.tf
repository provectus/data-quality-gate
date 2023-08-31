output "data_test_docker_image" {
  value = module.docker_image_data_test.image_uri
}

output "allure_report_docker_image" {
  value = module.docker_image_allure_report.image_uri
}
