#data "archive_file" "read_new_files" {
#  type        = "zip"
#  source_file = "${path.root}/../functions/read_new_files/read_new_files.py"
#  output_path = "read_new_files.zip"
#}
#
#resource "aws_lambda_function" "lambda_function_read_new_files" {
#  function_name    = "${local.resource_name_prefix}-read-new-files"
#  filename         = "read_new_files.zip"
#  source_code_hash = data.archive_file.read_new_files.output_base64sha256
#  role             = aws_iam_role.read_new_files_s3_lambda_role.arn
#  runtime          = "python3.7"
#  handler          = "read_new_files.lambda_handler"
#  timeout          = 10
#}

