resource "aws_dynamodb_table" "data_qa_report" {
  hash_key       = "file"
  name           = aws_ssm_parameter.data_qa_dynamo_table.value
  read_capacity  = 20
  write_capacity = 2
  stream_enabled = false

  attribute {
    name = "file"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }
  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
}

resource "aws_appautoscaling_target" "data_qa_report_table_read_target" {
  max_capacity       = 200
  min_capacity       = 50
  resource_id        = "table/${aws_dynamodb_table.data_qa_report.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "data_qa_report_read_policy" {
  name               = "dynamodb-read-capacity-utilization-${aws_appautoscaling_target.data_qa_report_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.data_qa_report_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.data_qa_report_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.data_qa_report_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 60
  }
}

resource "aws_appautoscaling_target" "data_qa_report_table_write_target" {
  max_capacity       = 50
  min_capacity       = 2
  resource_id        = "table/${aws_dynamodb_table.data_qa_report.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "data_qa_report_table_write_policy" {
  name               = "dynamodb-write-capacity-utilization-${aws_appautoscaling_target.data_qa_report_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.data_qa_report_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.data_qa_report_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.data_qa_report_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}