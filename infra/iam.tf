data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_sns_cloudwatch_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_sns_policy"
  description = "Policy for Lambda to access SNS, Cost Explorer, and CloudWatch Logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = [
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostForecast",
          "ce:GetDimensionValues",
          "ce:GetCostAndUsageWithResources"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}




resource "aws_iam_role" "scheduler_lambda_role" {
  name = "cron-scheduler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["scheduler.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "scheduler_lambda_policy" {
  name        = "scheduler-lambda-policy"
  description = "Policy for scheduler to access Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}_report"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_lambda_attachment" {
  role       = aws_iam_role.scheduler_lambda_role.name
  policy_arn = aws_iam_policy.scheduler_lambda_policy.arn
}



resource "aws_iam_role" "sns_lambda_role" {
  name = "sns_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["sns.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "sns_lambda_policy" {
  name        = "sns_lambda_policy"
  description = "Policy for SNS to invoke Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}_alert"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_lambda_attachment" {
  role       = aws_iam_role.sns_lambda_role.name
  policy_arn = aws_iam_policy.sns_lambda_policy.arn
}

resource "aws_sns_topic_policy" "budget_alert_policy" {
  arn    = aws_sns_topic.alert_sns_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSBudgets-notification-1"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = [
          "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic_name}"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:budgets::${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}