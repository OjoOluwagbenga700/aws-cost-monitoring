locals {
  lambda_configs = {
    alert = {
      source_dir  = "../lambda/budget_alert"
      output_path = "alert.zip"
      handler     = "alert.lambda_handler"
      env_vars = {
        SNS_TOPIC_ARN = aws_sns_topic.alert_sns_topic.arn
      }
    }
    report = {
      source_dir  = "../lambda/daily_report"
      output_path = "report.zip"
      handler     = "report.lambda_handler"
      env_vars = {
        SLACK_WEBHOOK_URL = var.slack_webhook_url
      }
    }
  }
}

data "archive_file" "lambda_zip" {
  for_each    = local.lambda_configs
  type        = "zip"
  source_dir  = each.value.source_dir
  output_path = each.value.output_path
}

resource "aws_lambda_function" "lambda_function" {
  for_each         = local.lambda_configs
  filename         = data.archive_file.lambda_zip[each.key].output_path
  function_name    = "${var.function_name}_${each.key}"
  role             = aws_iam_role.lambda_role.arn
  handler          = each.value.handler
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip[each.key].output_path)
  runtime          = "python3.9"
  environment {
    variables = each.value.env_vars
  }
}