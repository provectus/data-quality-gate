#!/usr/bin/python3.8
import os
import urllib3
import json

http = urllib3.PoolManager()


def lambda_handler(event, context):
    url = os.environ["SLACK_WEBHOOK_URL"]

    
    body = {
        "channel": "#{}".format(os.environ["SLACK_CHANNEL"]),
        "username": os.environ["SLACK_USERNAME"],
        "icon_emoji": "",
    }

    body = update_body_from_event(body, event)

    encoded_msg = json.dumps(body).encode("utf-8")
    resp = http.request("POST", url, body=encoded_msg)
    print(
        {
            "message": str(body),
            "status_code": resp.status,
            "response": resp.data,
        }
    )

def update_body_from_event(body, event):

    if type(event).__name__ == "dict": 
        if event["Records"] and event["Records"][0]["EventSource"] == 'aws:sns':
            sns_message = event["Records"][0]["Sns"]["Message"]            
            sns_message_json = json.loads(sns_message)
            if sns_message_json['AlarmName']:
                body = update_body_from_cloudwatch_sns_alarm(body, sns_message_json)
            else:
                body['text'] = json.dumps(sns_message_json, indent=2)
        else:
            print("No defined message type so sending full event as message")
            body['text'] = str(event)

    else:
        print("Event type not a dictionary so return event converted to string")
        body['text'] = str(event)
    
    return body

def update_body_from_cloudwatch_sns_alarm(body, sns_message_json):
    alarm_name = sns_message_json['AlarmName']
    alarm_description = sns_message_json['AlarmDescription']
    aws_account_id = sns_message_json['AWSAccountId']
    current_state = sns_message_json['NewStateValue']
    state_change_time = sns_message_json['StateChangeTime']
    region = sns_message_json['Region']

    in_alarm_color = "#A60000"
    ok_alarm_color = "#2EB886"

    current_color = in_alarm_color if current_state == 'ALARM' else ok_alarm_color

    # Add simple text which will be displayed in mobile notifications
    body['text'] = "Cloudwatch Alarm ({status}) - {alarm}".format(status=current_state, alarm=alarm_name)

    # Add attachments which will display colored blockquotes depending on alarm or ok state
    body["attachments"] = [{
        "color": current_color,
        "blocks": [
            {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "Cloudwatch Alarm"
            }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": "*Status*: {status}\n".format(status=current_state)
                    }
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*{alarm}*\n_{alarm_desc}_".format(alarm=alarm_name, alarm_desc=alarm_description)
                }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": "*AWS Account*:\n{account}".format(account=aws_account_id)
                    },
                    {
                        "type": "mrkdwn",
                        "text": "*AWS Region*:\n{aws_region}".format(aws_region=region)
                    }
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*Time*: {time}".format(time=state_change_time)
                }
            }
        ]
    }]

    return body