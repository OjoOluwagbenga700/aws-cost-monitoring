import json
import boto3
import os

sns = boto3.client("sns")

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    # Handle both SNS and direct invocation
    if "Records" in event and "Sns" in event["Records"][0]:
        sns_message = json.loads(event["Records"][0]["Sns"]["Message"])
    else:
        # Assume direct invocation with the message as the event
        sns_message = event if isinstance(event, dict) else {}

    # Extract budget alert data
    budget_name = sns_message.get("budgetName", "N/A")
    current_spend = sns_message.get("newActual", "0")
    budget_limit = sns_message.get("budgetLimit", "0")
    forecasted = sns_message.get("newForecast", "0")
    threshold = sns_message.get("threshold", "0")

    # Format the alert message
    formatted_message = f"""
🚨 AWS Budget Alert Triggered 🚨

📛 Budget Name: {budget_name}
💰 Current Spend: ${current_spend}
📊 Budget Limit: ${budget_limit}
🔮 Forecasted Spend: ${forecasted}
⚠️ Threshold Breached: {threshold}%

This alert was triggered by your AWS Budget configuration.
"""

    print("Formatted Message:", formatted_message)

    # Send to SNS topic (which will deliver to email)
    response = sns.publish(
        TopicArn=os.environ["SNS_TOPIC_ARN"],
        Subject="AWS Budget Alert 🚨",
        Message=formatted_message
    )

    print("SNS Publish Response:", response)
    return {"statusCode": 200, "body": "Alert processed and published"}