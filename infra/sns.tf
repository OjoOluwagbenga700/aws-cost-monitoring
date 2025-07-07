resource "aws_sns_topic" "alert_sns_topic" {
  name = var.sns_topic_name
}


resource "aws_sns_topic_subscription" "lambda_alert_trigger" {
  topic_arn = aws_sns_topic.alert_sns_topic.arn
  protocol  = "email"
  endpoint  = "ojosamuel700@gmail.com"
}
