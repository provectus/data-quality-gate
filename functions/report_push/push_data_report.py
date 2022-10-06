import os
import sys
import s3fs
import boto3
import boto
import boto.s3
import re
import fnmatch
from datetime import date
import json
import awswrangler as wr
import random

from functions.jira.jira_events import create_bug

cloudWatch = boto3.client('cloudwatch')
s3 = boto3.resource('s3')
dynamodb = boto3.resource('dynamodb')
dynamo_table_name = os.environ['QA_DYNAMODB_TABLE']
table = dynamodb.Table(dynamo_table_name)
qa_bucket = os.environ['QA_BUCKET']
environment = os.environ['ENVIRONMENT']

def handler(event, context):

    replaced_allure_links = event['links'].get('Payload')
    report = event['report'].get('Payload')
    profiling_link = (report.get('profiling'))
    ge_links = report.get('test_suite')
    suite = report.get('suite_name')
    today = str(date.today())
    path = report.get('path')
    file = report.get('suite_name')
    key = report.get('folder_key')
    run_name = report.get('run_name')
    items = []
    df = wr.s3.read_json(path=['s3://'+qa_bucket+'/allure/' + suite + '/' + key + '/allure-report/history/history-trend.json'])
    result_df = wr.s3.read_json(path=['s3://'+qa_bucket+'/allure/' + suite + '/' + key + '/allure-report/results/'])
    pattern = "*-result.json"
    for entry in os.listdir(result_df):
        if fnmatch.fnmatch(entry, pattern):
            result_file = open("results/" + entry)
            result = json.load(result_file)
            status = result['status']
            if status == "passed":
                print("Result is passed, try next")
            if status == "failed":
                table_name = result['labels'][1]['value']
                fail_step = result['steps'][0]['name']
                description = result['description']
                create_bug("IPA", table_name[:table_name.find('.')], fail_step[:fail_step.find('.')], description)
    history = json.loads(df.to_json())
    total = history['data']['0']['total']
    failed = history['data']['0']['failed']
    passed = history['data']['0']['passed']
    if failed != 0:
        status = 'failed'
    else:
        status = 'passed'
    local_item = {
            'file':str(random.random()),
            'file_name': file,
            'all': total,
            'allure_link': replaced_allure_links,
            'date': today,
            'failed': failed,
            'ge_link': ge_links,
            'passed': passed,
            'profiling_link': profiling_link,
            'status': status,
            'suite': suite,
            'path': str(path),
            'run_name': run_name
        }
    items.append(local_item)

    with table.batch_writer() as batch:
        for item in items:
            print(item)
            batch.put_item(
                Item=item
            )

    cloudWatch.put_metric_data(
        Namespace='Data-QA',
        MetricData=[
            {
                'MetricName': 'suite_failed_count',
                'Dimensions': [
                    {
                        'Name': 'table_name',
                        'Value': suite
                    },
                    {
                        'Name': 'Environment',
                        'Value': environment
                    }
                ],
                'Value': failed,
                'Unit': 'Count'
            },
        ]
    )
    return "Dashboard is ready!"
