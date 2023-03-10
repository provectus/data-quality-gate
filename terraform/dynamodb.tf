resource "aws_dynamodb_table" "data_qa_report" {
  hash_key       = "file"
  name           = "${local.resource_name_prefix}-dynamodb_report_table"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  stream_enabled = var.dynamodb_stream_enabled

  attribute {
    name = "file"
    type = "S"
  }

  dynamic "attribute" {
    for_each = var.dynamodb_table_attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  point_in_time_recovery {
    enabled = false
  }

  lifecycle {
    ignore_changes = [write_capacity, read_capacity]
  }
}

resource "aws_appautoscaling_target" "data_qa_report_table_read_target" {
  min_capacity = var.dynamodb_report_table_autoscaling_read_capacity_settings.min
  max_capacity = var.dynamodb_report_table_autoscaling_read_capacity_settings.max

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
    target_value = var.dynamodb_report_table_read_scale_threshold
  }
}

resource "aws_appautoscaling_target" "data_qa_report_table_write_target" {
  min_capacity = var.dynamodb_report_table_autoscaling_write_capacity_settings.min
  max_capacity = var.dynamodb_report_table_autoscaling_write_capacity_settings.max

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
    target_value = var.dynamodb_report_table_write_scale_threshold
  }
}