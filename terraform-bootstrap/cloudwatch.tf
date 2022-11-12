resource "aws_cloudwatch_log_group" "this" {
  name              = "/${var.project}/${var.environment}/logs"
  retention_in_days = "60"
}