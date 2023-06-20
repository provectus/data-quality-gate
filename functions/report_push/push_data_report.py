import os
import boto3
from datetime import date
import json
import awswrangler as wr
import random
from jira_events import auth_in_jira, get_all_issues, open_bug

s3 = boto3.resource('s3')
sns = boto3.client('sns')

dynamodb = boto3.resource('dynamodb')
dynamo_table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(dynamo_table_name)
qa_bucket = os.environ['BUCKET']
environment = os.environ['ENVIRONMENT']
sns_bugs_topic = os.environ.get('SNS_BUGS_TOPIC_ARN', None)
autobug = False


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
    created_bug_count = 0
    bug_name = []
    items = []
    df = wr.s3.read_json(
        path=[
            f"s3://{qa_bucket}/allure/{suite}/{key}"
            f"/allure-report/history/history-trend.json"
        ]
    )
    history = json.loads(df.to_json())
    total = history['data']['0']['total']
    failed = history['data']['0']['failed']
    passed = history['data']['0']['passed']
    if failed != 0:
        status = 'failed'
        report = {
            "failed_test_count": failed,
        }
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
        'created_bug_count': created_bug_count
    }
    items.append(local_item)

    with table.batch_writer() as batch:
        for item in items:
            batch.put_item(Item=item)

    pipeline_config = json.loads(wr.s3.read_json(
        path=f"s3://{qa_bucket}/test_configs/pipeline.json").to_json())
    try:
        autobug = pipeline_config[run_name]['autobug']
    except KeyError:
        autobug = False
        print(f"Can't find autobug param for {run_name}")
    try:
        only_failed = pipeline_config[run_name]["only_failed"]
    except KeyError:
        only_failed = True
        print(f"Can't find only_failed param for {run_name}")

    if autobug and failed:
        jira_project_key = os.environ['JIRA_PROJECT_KEY']
        auth_in_jira()
        created_bug_count, bug_name = create_jira_bugs_from_allure_result(
            bucket, key, replaced_allure_links, suite, jira_project_key)

    cloudwatch = boto3.client('cloudwatch')
    push_cloudwatch_metrics(suite,
                            environment,
                            failed,
                            created_bug_count,
                            cloudwatch)
    push_sns_message(
        suite,
        run_name,
        file,
        bug_name,
        created_bug_count,
        replaced_allure_links,
        total,
        failed,
        passed,
        sns_bugs_topic,
        only_failed)

    return report


def create_jira_bugs_from_allure_result(
        bucket,
        key,
        replaced_allure_links,
        suite,
        jira_project_key):
    created_bug_count = 0
    bug_name = []
    all_result_files = bucket.objects.filter(
        Prefix=f"allure/{suite}/{key}/result/")
    issues = get_all_issues(jira_project_key)
    for result_file_name in all_result_files:
        if result_file_name.key.endswith('result.json'):
            content_object = s3.Object(qa_bucket, result_file_name.key)
            data_in_file = json.load(content_object.get()['Body'])
            status = data_in_file['status']
            if status == "failed":
                created_bug_count += 1
                table_name = data_in_file["labels"][1]["value"]
                fail_step = data_in_file["steps"][0]["name"]
                description = data_in_file["description"]
                bug_name.append(open_bug(
                    table_name[: table_name.find(".")],
                    fail_step[: fail_step.find(".")],
                    description,
                    f"https://{replaced_allure_links}",
                    issues,
                    jira_project_key,
                ))
    return created_bug_count, bug_name


def push_sns_message(
        suite,
        run_name,
        file,
        bug_name,
        created_bug_count,
        replaced_allure_links,
        total,
        failed,
        passed,
        sns_bugs_topic,
        only_failed):
    message_structure = 'json'
    allure_link = f"http://{replaced_allure_links}"
    if created_bug_count > 0:
        sns_message = {
            "table": suite,
            "pipeline_step": run_name,
            "source_name": file,
            "new_bugs": bug_name,
            "new_bugs_count": created_bug_count,
            "allure_report": allure_link
        }
    elif failed > 0:
        sns_message = {
            "table": suite,
            "pipeline_step": run_name,
            "source_name": file,
            "all": total,
            "failed": failed,
            "passed": passed,
            "allure_report": allure_link
        }
    else:
        sns_message = f"All {total} tests for source: {suite} were successful"
        message_structure = 'string'

    if message_structure == 'json':
        sns_message = json.dumps({"default": json.dumps(sns_message)})

    if only_failed and message_structure == 'json' or not only_failed:
        sns.publish(TopicArn=sns_bugs_topic,
                    Message=sns_message,
                    MessageStructure=message_structure)


def push_cloudwatch_metrics(suite,
                            environment,
                            failed,
                            created_bug_count,
                            cloudwatch):
    if created_bug_count > 0:
        metric_data = {
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
            'Value': created_bug_count,
            'Unit': 'Count'
        }
    else:
        metric_data = {
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
        }
    cloudwatch.put_metric_data(
        Namespace='Data-QA',
        MetricData=[
            metric_data,
        ]
    )
