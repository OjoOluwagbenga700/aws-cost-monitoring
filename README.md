# AWS Cost Monitoring & Budget Alert Automation

This project automates AWS cost monitoring and alerting using a **serverless architecture** powered by:
- **AWS Budgets** (for tracking spending thresholds)
- **AWS Lambda** (for processing alerts and generating daily reports)
- **Amazon SNS** (for email alerts)
- **EventBridge** (for scheduled daily reports)
- **Slack Webhooks** (for real-time notifications)
- **Terraform** (for full Infrastructure as Code)

---

## 💡 What It Does

✅ Sends a **daily AWS cost summary to Slack** via a configured Webhook URL  
✅ Triggers **email alerts via SNS** when the AWS monthly budget threshold is exceeded  
✅ Uses a Lambda function to process and format budget alerts before forwarding to subscribers

---

## 🛠 Technologies Used
- AWS Lambda
- AWS SNS
- AWS Budgets
- EventBridge (CloudWatch Scheduler)
- Slack Webhook
- Python 3.9
- Terraform

---

## 📁 Folder Structure
```
├── README.md
├── infra
│   ├── eventbridge.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── output.tf
│   ├── sns.tf
│   ├── terraform.tf
│   └── variable.tf
└── lambda
    ├── budget_alert
    │   └── alert.py
    └── daily_report
        └── report.py
```

---

## 🚀 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/aws-cost-monitoring.git
cd aws-cost-monitoring
```

### 2. Generate a Slack Webhook URL
To receive cost alerts in Slack:
1. Go to your Slack workspace
2. Navigate to **Apps** and search for **Incoming Webhooks**
3. Click **Add to Slack**
4. Select a channel where messages should appear
5. Click **Add Incoming Webhooks integration**
6. Copy the **Webhook URL** provided (e.g., `https://hooks.slack.com/services/...`)

### 3. provide the values of the following to `variable.tf`
```hcl
slack_webhook_url     = "https://hooks.slack.com/services/..."
alert_email_address   = "your@email.com"
```

### 4. Deploy the Infrastructure
```bash
cd infra
terraform init
terraform plan
terraform apply --auto-approve
```
📬 Check your inbox to verify the SNS email subscription!

### 5. Configure the AWS Budget Manually
Go to the AWS Console → **Budgets** → Create a monthly cost budget manually with the following:
- Budget type: Cost
- Threshold: 80% or any value you prefer
- Budget Alert: **SNS Topic** created by Terraform (e.g., `aws-budget-alerts`)

### 6. (Optional) Terraform Destroy
To remove the infrastructure when you're done testing:
```bash
terraform destroy
```
---










---

