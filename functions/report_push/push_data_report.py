import boto3
from datetime import date
import json
import awswrangler as wr
import random
s3 = boto3.resource('s3')
ssm = boto3.client('ssm')
dynamodb = boto3.resource('dynamodb')
dynamo_table_name = ssm.get_parameter(Name='/data-qa/dynamo-table', WithDecryption=True)['Parameter']['Value']
table = dynamodb.Table(dynamo_table_name)
qa_bucket = ssm.get_parameter(Name='/data-qa/qa-bucket', WithDecryption=True)['Parameter']['Value']
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
    items = []

    df = wr.s3.read_json(path=['s3://'+qa_bucket+'/allure/' + suite + '/' + key + '/allure-report/history/history-trend.json'])
    history = json.loads(df.to_json())
    total = history['data']['0']['total']
    failed = history['data']['0']['failed']
    passed = history['data']['0']['passed']
    skipped = history['data']['0']['skipped']
    broken = history['data']['0']['broken']
    if failed != 0:
        status = 'failed'
    else:
        status = 'passed'

    local_item = {
            'file':str(random.random()),
            'file_name': file,
            'all': total,
            'allure_link': replaced_allure_links,
            'broken': broken,
            'date': today,
            'failed': failed,
            'ge_link': ge_links,
            'passed': passed,
            'profiling_link': profiling_link,
            'skipped': skipped,
            'status': status,
            'suite': suite,
            'path': path
        }
    items.append(local_item)

    with table.batch_writer() as batch:
        for item in items:
            print(item)
            batch.put_item(
                Item=item
            )
    return "Dashboard is ready!"
