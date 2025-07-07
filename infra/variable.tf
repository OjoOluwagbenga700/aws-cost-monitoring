variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

}

variable "email_endpoint" {
  description = "Email address to send budget alerts from"
  type        = string
  default     = "ojosamuel700@gmail.com"
}


variable "slack_webhook_url" {
  description = "Slack webhook URL for sending notifications"
  type        = string
  default     = "slack_webhook_url_placeholder"

}

variable "function_name" {
  description = "Base name for the Lambda functions"
  type        = string
  default     = "cost_management_lambda"
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for budget alerts"
  type        = string
  default     = "budget_alert_topic"
}

