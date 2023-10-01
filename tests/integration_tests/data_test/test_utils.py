import boto3
import requests
import json
import os


def read_json_file(s3, bucket_name,  file_path):
    content_object = s3.Object(bucket_name, file_path)
    file_content = content_object.get()['Body'].read().decode('utf-8')
    return json.loads(file_content)


def delete_s3_file(s3, bucket_name: str, file_path: str):
    s3.Object(bucket_name, file_path).delete()


def upload_file_to_s3(s3, bucket_name: str, file_path: str, file_name: str):
    local_path = f"./test_data/{file_name}"
    s3.create_bucket(Bucket=bucket_name)
    s3.Object(bucket_name, file_path).put(Body=open(local_path, 'rb'))


def create_boto_s3_resource():
    host = os.environ["S3_HOST"]
    url = f"http://{host}:4566"
    s3 = boto3.resource("s3", endpoint_url=url,
                        aws_access_key_id="test",
                        aws_secret_access_key="test")
    return s3


def invoke_lambda(file_path: str):
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
