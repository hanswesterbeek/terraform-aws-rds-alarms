// CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "Average database CPU utilization is too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  alarm_name          = "gateway-RDS-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = []
  ok_actions          = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.gateway-kong.id
  }
}

// Disk Utilization
resource "aws_cloudwatch_metric_alarm" "disk_burst_balance_too_low" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowEBSBurstBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_too_high" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highDiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "64"
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space_too_low" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowFreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "10000000000" // 10 GB
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

// Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory_freeable_too_low" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage_too_high" {
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highSwapUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_description   = "Average database swap usage is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

// Connection Count
resource "aws_cloudwatch_metric_alarm" "connection_count_anomalous" {
  alarm_name                = "${var.prefix}rds-${var.db_instance_id}-anomalousConnectionCount"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = var.evaluation_period
  threshold_metric_id       = "e1"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = var.actions_alarm
  ok_actions                = var.actions_ok

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = var.anomaly_period
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.db_instance_id
      }
    }
  }
}
