import boto3


def handler(event, context):
    print(event)
    bucket_name = "dqg-settings-dev"
    bucket_key = "test_configs/manifest.json"
    s3 = boto3.resource("s3")
    content = s3.Object(bucket_name, bucket_key).get()["Body"].read().decode("utf-8")
    print(content)
    return 0
