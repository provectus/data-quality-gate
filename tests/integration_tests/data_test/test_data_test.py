from jsonschema import validate
import boto3
import pytest
import requests
import json
import os

schema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "path": {
            "type": "array",
            "items": [
                {
                    "type": "string"
                }
            ]
        },
        "file": {
            "type": "string"
        },
        "profiling": {
            "type": "string"
        },
        "test_suite": {
            "type": "string"
        },
        "suite_name": {
            "type": "string"
        },
        "folder_key": {
            "type": "string"
        },
        "run_name": {
            "type": "string"
        },
        "validate_id": {
            "type": "string"
        }
    },
    "required": [
        "path",
        "file",
        "profiling",
        "test_suite",
        "suite_name",
        "folder_key",
        "run_name",
        "validate_id"
    ]
}


@pytest.fixture(scope="function")
def s3_test_data(request):
    bucket_name = "dataqa"
    file_name = request.param
    file_path = f"{bucket_name}/{file_name}"
    s3 = _create_boto_s3_resource()
    _upload_file_to_s3(s3, bucket_name, file_path, file_name)
    response = _invoke_lambda(file_path)
    json_response = json.loads(response.text)
    validate(instance=json_response, schema=schema)
    yield file_path
    _delete_s3_file(s3, bucket_name, file_path)


@pytest.mark.parametrize("s3_test_data",
                         ["titanic.csv",
                          "titanic.parquet",
                          "titanic.json",
                          "titanic_nested.json"],
                         indirect=True)
def test_data_test(s3_test_data: str):
    pass


def _delete_s3_file(s3, bucket_name: str, file_path: str):
    s3.Object(bucket_name, file_path).delete()


def _upload_file_to_s3(s3, bucket_name: str, file_path: str, file_name: str):
    local_path = f"./test_data/{file_name}"
    s3.create_bucket(Bucket=bucket_name)
    s3.Object(bucket_name, file_path).put(Body=open(local_path, 'rb'))


def _create_boto_s3_resource():
    host = os.environ["S3_HOST"]
    url = f"http://{host}:4566"
    s3 = boto3.resource("s3", endpoint_url=url,
                        aws_access_key_id="test",
                        aws_secret_access_key="test")
    return s3


def _invoke_lambda(file_path: str):
    lambda_host = os.environ["LAMBDA_HOST"]
    lambda_port = os.environ["LAMBDA_PORT"]
    lambda_url = f"http://{lambda_host}:{lambda_port}/2015-03-31/functions/function/invocations"

    payload = json.dumps({
        "run_name": "local_test",
        "source_root": "dataqa",
        "source_data": f"{file_path}",
        "engine": "s3"
    })
    headers = {
        'Content-Type': 'application/json'
    }
    response = requests.request("POST",
                                lambda_url,
                                headers=headers,
                                data=payload)
    return response
