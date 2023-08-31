import boto3
import json
import os

step_name = os.getenv("STEP_NAME")

def write_output(output):
    #Here the right place to wrap_up and generate output
    with open(f"/tmp/{step_name}.json", "w") as outfile:
        json.dump(output, outfile)

    return 0

def handler(event, context):
    if step_name == "s3":
        bucket_name = "dqg-settings-dev"
        bucket_key = "test_configs/manifest.json"
        s3 = boto3.resource("s3")
        content = s3.Object(bucket_name, bucket_key).get()["Body"].read().decode("utf-8")
        write_output(json.loads(content))
    elif step_name == "modify":
        write_output(event['fileLocations'])
    else:
        print(event)

    return 0
