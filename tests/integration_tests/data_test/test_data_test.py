# import data_test as ds
# import awswrangler as wr
import os
from jsonschema import validate
import boto3
import pytest
import requests
import json

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
    host = 'localhost'
    # url = f"http://{os.environ['S3_HOST']}:4566"
    url = f"http://{host}:4566"
    # wr.config.s3_endpoint_url = url
    b_name = "dataqa"
    file_name = request.param
    file_path = f"{b_name}/{file_name}"
    local_path = f"./tests/integration_tests/data_test/test_data/{file_name}"
    # event = {
    #     "run_name": "local_test",
    #     "source_root": b_name,
    #     "source_data": file_path,
    #     "engine": "s3"
    # }
    s3 = boto3.resource("s3", endpoint_url=url)
    # qa_bucket_name = os.environ['BUCKET']
    qa_bucket_name = "dqg-settings-local"
    # gx_config_local_path = "./great_expectations/great_expectations.yml"
    # config_path = f"{qa_bucket_name}/great_expectations/great_expectations.yml"
    # s3.Bucket(qa_bucket_name).download_file(config_path, gx_config_local_path)
    s3.create_bucket(Bucket=b_name)
    s3.Object(b_name, file_path).put(Body=open(local_path, 'rb'))
    url = "http://localhost:9000/2015-03-31/functions/function/invocations"

    payload = json.dumps({
        "run_name": "local_test",
        "source_root": "dataqa",
        "source_data": "dataqa/titanic.csv",
        "engine": "s3"
    })
    headers = {
        'Content-Type': 'application/json'
    }

    response = requests.request("POST", url, headers=headers, data=payload)
    # result = ds.handler(event, {})
    json_response = json.loads(response.text)
    validate(instance=json_response, schema=schema)
    yield file_path
    s3.Object(b_name, file_path).delete()


@pytest.mark.parametrize("s3_test_data", ["titanic.csv"],
                        #  ["titanic.csv",
                        #                   "titanic.parquet",
                        #                   "titanic.json",
                        #                   "titanic_nested.json"],
                         indirect=True)
def test_data_test(s3_test_data):
    pass
