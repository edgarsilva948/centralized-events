import json
import os
import boto3
from botocore.vendored import requests

SLACK_URL = os.environ.get('SLACK_URL')

def lambda_handler(event, context):
    formatted = format_message(event)
    send_to_slack(formatted)

def format_message(parameter_event):
    print(parameter_event)
    region = parameter_event.get("region")
    account = parameter_event.get("account")
    creation_event = parameter_event.get('detail').get('responseElements').get('instancesSet').get('items')
    instance_id = creation_event[0].get('instanceId')  
    instance_type = parameter_event.get('detail').get('requestParameters').get('instanceType')

    text = '\n'.join([
        "*Cloudtrail* - An EC2 Instance has been created!",
        "- Account: *{}*".format(account),
        "- Region: *{}*".format(region),
        "- InstanceID: *{}*".format(instance_id),
        "- InstanceType: *{}*".format(instance_type),
    ])

    return {
        "text": text
    }   
        
def send_to_slack(message, url=SLACK_URL):
    resp = requests.post(url, json=message)
    resp.raise_for_status()