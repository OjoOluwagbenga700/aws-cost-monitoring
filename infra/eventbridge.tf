resource "aws_scheduler_schedule" "report_scheduler" {
  name       = "report-schedule"
  group_name = "default"


  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 10 * * ? *)"
  schedule_expression_timezone = "Africa/Lagos"
  target {
    arn      = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}_report"
    role_arn = aws_iam_role.scheduler_lambda_role.arn
  }
}