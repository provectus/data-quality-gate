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

from jira_events import *

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
    bucket = s3.Bucket(qa_bucket)
    failed_test_count_from_results = ''
    items = []
    if "JIRA_PROJECT_KEY" in os.environ:
        jira_project_key = os.environ['JIRA_PROJECT_KEY']
        auth_in_jira()
        failed_test_count_from_results = create_jira_bugs_from_allure_result(bucket, key, replaced_allure_links, suite,
                                                                             jira_project_key)
    df = wr.s3.read_json(path=[f's3://{qa_bucket}/allure/{suite}/{key}/allure-report/history/history-trend.json'])
    history = json.loads(df.to_json())
    total = history['data']['0']['total']
    failed = history['data']['0']['failed']
    passed = history['data']['0']['passed']
    if failed != 0:
        status = 'failed'
    else:
        status = 'passed'
    local_item = {
        'file': str(random.random()),
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
        'run_name': run_name,
        'failed_test_count_from_results': failed_test_count_from_results
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
                'MetricName': 'bug_created_count',
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
                'Value': failed_test_count_from_results,
                'Unit': 'Count'
            },
        ]
    )
    return "Dashboard is ready!"


def create_jira_bugs_from_allure_result(bucket, key, replaced_allure_links, suite, jira_project_key):
    failed_test_count_from_results = 0
    all_result_files = bucket.objects.filter(Prefix=f'allure/{suite}/{key}/result/')
    issues = get_all_issues(jira_project_key)
    for result_file_name in all_result_files:
        if result_file_name.key.endswith('result.json'):
            content_object = s3.Object(qa_bucket, result_file_name.key)
            dataInFile = json.load(content_object.get()['Body'])
            status = dataInFile['status']
            if status == "failed":
                failed_test_count_from_results += 1
                tableName = dataInFile['labels'][1]['value']
                failStep = dataInFile['steps'][0]['name']
                description = dataInFile['description']
                open_bug(tableName[:tableName.find('.')], failStep[:failStep.find('.')], description,
                         f'https://{replaced_allure_links}', issues)
    return failed_test_count_from_results
