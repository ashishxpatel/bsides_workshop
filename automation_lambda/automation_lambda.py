"""Automation Lambda responds to Splunk alerts and takes actions"""

import json
import boto3


def lambda_handler(event, context):
    """Handle alerts from Splunk and automate all the things"""
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    action = message["message"]
    alert_data = json.loads(message["event"])
    search_name = message["search_name"]
    print("Hello, World")
