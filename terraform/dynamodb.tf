resource "aws_dynamodb_table" "data_qa_report" {
  hash_key       = var.dynamodb_hash_key
  name           = "${local.resource_name_prefix}-dynamodb_report_table"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  stream_enabled = var.dynamodb_stream_enabled

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

resource "aws_appautoscaling_target" "data_qa_report_table_read" {
  min_capacity = var.dynamodb_read_capacity
  max_capacity = var.dynamodb_autoscaling_read["max_capacity"]

  resource_id        = "table/${aws_dynamodb_table.data_qa_report.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "data_qa_report_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.data_qa_report_table_read.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.data_qa_report_table_read.resource_id
  scalable_dimension = aws_appautoscaling_target.data_qa_report_table_read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.data_qa_report_table_read.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = lookup(var.dynamodb_autoscaling_read, "scale_in_cooldown", var.dynamodb_autoscaling_defaults["scale_in_cooldown"])
    scale_out_cooldown = lookup(var.dynamodb_autoscaling_read, "scale_out_cooldown", var.dynamodb_autoscaling_defaults["scale_out_cooldown"])
    target_value       = lookup(var.dynamodb_autoscaling_read, "target_value", var.dynamodb_autoscaling_defaults["target_value"])
  }
}

resource "aws_appautoscaling_target" "data_qa_report_table_write" {
  min_capacity = var.dynamodb_write_capacity
  max_capacity = var.dynamodb_autoscaling_write["max_capacity"]

  resource_id        = "table/${aws_dynamodb_table.data_qa_report.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "data_qa_report_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.data_qa_report_table_write.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.data_qa_report_table_write.resource_id
  scalable_dimension = aws_appautoscaling_target.data_qa_report_table_write.scalable_dimension
  service_namespace  = aws_appautoscaling_target.data_qa_report_table_write.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = lookup(var.dynamodb_autoscaling_write, "scale_in_cooldown", var.dynamodb_autoscaling_defaults["scale_in_cooldown"])
    scale_out_cooldown = lookup(var.dynamodb_autoscaling_write, "scale_out_cooldown", var.dynamodb_autoscaling_defaults["scale_out_cooldown"])
    target_value       = lookup(var.dynamodb_autoscaling_write, "target_value", var.dynamodb_autoscaling_defaults["target_value"])
  }
}