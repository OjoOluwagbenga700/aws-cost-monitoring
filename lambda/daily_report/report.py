import boto3
import datetime
import os
import json
import urllib.request

def lambda_handler(event, context):
    ce = boto3.client('ce')
    today = datetime.date.today()
    yesterday = today - datetime.timedelta(days=1)

    # Daily cost
    daily_response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': yesterday.strftime('%Y-%m-%d'),
            'End': today.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )

    groups = daily_response['ResultsByTime'][0]['Groups']
    total_daily = 0.0
    if 'UnblendedCost' in daily_response['ResultsByTime'][0]['Total']:
        total_daily = float(daily_response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount'])

    # Month-to-date cost
    month_start = today.replace(day=1)
    mtd_response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': month_start.strftime('%Y-%m-%d'),
            'End': today.strftime('%Y-%m-%d')
        },
        Granularity='MONTHLY',
        Metrics=['UnblendedCost']
    )
    total_mtd = 0.0
    if 'UnblendedCost' in mtd_response['ResultsByTime'][0]['Total']:
        total_mtd = float(mtd_response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount'])

    # Format Slack message
    report = [f"💰 *AWS Daily Cost Report* ({yesterday}):"]
    for g in groups:
        svc = g['Keys'][0]
        amount = float(g['Metrics']['UnblendedCost']['Amount'])
        if amount > 0:
            report.append(f"- {svc}: *${amount:.2f}*")
    report.append(f"\n*Total Spend (Yesterday):* `${total_daily:.2f}`")
    report.append(f"*Total Spend (Month-to-date):* `${total_mtd:.2f}`")

    # Send to Slack using urllib
    webhook_url = os.environ['SLACK_WEBHOOK_URL']
    payload = json.dumps({"text": "\n".join(report)}).encode("utf-8")

    request = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={"Content-Type": "application/json"}
    )

    try:
        with urllib.request.urlopen(request) as response:
            response_body = response.read().decode("utf-8")
    except Exception as e:
        print(f"Error posting to Slack: {e}")
        return {
            'statusCode': 500,
            'body': 'Failed to send cost report to Slack.'
        }

    return {
        'statusCode': 200,
        'body': 'Daily and month-to-date cost report sent successfully.'
    }
