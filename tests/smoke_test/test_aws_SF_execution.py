import time

import boto3
import botocore
import json
from loguru import logger
import os

REGION_NAME = os.environ['REGION_NAME']
PROFILE_NAME = os.environ['PROFILE_NAME']
STATE_MACHINE_ARN = os.environ['STATE_MACHINE_ARN']

session = boto3.Session(profile_name=PROFILE_NAME)
s3 = session.client('s3', region_name=REGION_NAME)
sfn_client = boto3.client('stepfunctions', region_name=REGION_NAME)


def file_upload(local_file_path, destination_path, bucket_name):
    try:
        s3.upload_file(local_file_path, bucket_name, destination_path)
        logger.info(f'File {local_file_path} successfully copied to {bucket_name}/{destination_path}')
    except botocore.exceptions.NoCredentialsError:
        logger.info('Failed to find AWS credentials. Ensure that AWS CLI is configured or use IAM roles.')
    except Exception as e:
        logger.info(f'An error occurred while copying the file: {str(e)}')


def run_step_function():
    input_data = {
        "files": [
            {
                "engine": "s3",
                "run_name": "raw_s3",
                "source_root": "dqg-data-storage",
                "source_data": [
                    "titanic.parquet"
                ]
            }
        ]
    }

    execution = sfn_client.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        input=json.dumps(input_data)
    )

    execution_arn = execution['executionArn']
    logger.info(f"Execution started with ARN: {execution_arn}")
    return execution_arn


def get_sf_execution_status(execution_arn):
    max_iterations = 100
    for _ in range(max_iterations):
        response = sfn_client.describe_execution(executionArn=execution_arn)
        status = response['status']
        logger.info(f"Execution status: {status}")

        if status in ["SUCCEEDED", "FAILED"]:
            break
        time.sleep(10)
    else:
        logger.warning("Maximum iterations reached. Exiting loop.")


def get_sf_events_status(execution_arn):
    events_response = sfn_client.get_execution_history(
        executionArn=execution_arn, reverseOrder=False, maxResults=1000
    )
    events = events_response["events"]
    for event in events:
        if event["type"] == "TaskFailed":
            logger.info("TaskFailed")
            event_details = json.loads(event["taskFailedEventDetails"]["cause"])
            logger.info(event_details)
            return "TaskFailed", event_details
    return "SUCCEEDED", None


def test_aws_step_function():
    file_upload("test_data/pipeline.json", "test_configs/pipeline.json", "dqg-settings-dev")
    file_upload("test_data/titanic.parquet", "titanic.parquet", "dqg-data-storage")
    execution_arn = run_step_function()
    get_sf_execution_status(execution_arn)
    execution_status, event_details = get_sf_events_status(execution_arn)
    assert execution_status == "SUCCEEDED", f"Test failed. Execution status: {execution_status}. With: {event_details}"
