import data_test
import awswrangler as wr
import os
from jsonschema import validate
import boto3


def test_data_test_csv():
    url = f"http://{os.environ['S3_HOST']}:4566"
    wr.config.s3_endpoint_url = url
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
    b_name = "dataqa"
    file_name = "titanic.csv"
    file_path = f"{b_name}/{file_name}"
    local_path = f"./test_data/{file_name}"
    event = {
      "run_name": "local_test",
      "source_root": b_name,
      "source_data": file_path,
      "engine": "s3"
    }
    s3 = boto3.resource("s3", endpoint_url=url)
    qa_bucket_name = os.environ['QA_BUCKET']
    gx_config_local_path = "./great_expectations/great_expectations.yml"
    config_path = f"{qa_bucket_name}/great_expectations/great_expectations.yml"
    s3.Bucket(qa_bucket_name).download_file(config_path, gx_config_local_path)
    s3.create_bucket(Bucket=b_name)
    s3.Object(b_name, file_path).put(Body=open(local_path, 'rb'))
    result = data_test.handler(event, {})
    validate(instance=result, schema=schema)
