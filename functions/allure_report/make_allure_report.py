from mapper import create_json_report
import os
import sys
import s3fs
import boto3
import boto
import boto.s3
import time

def handler(event, context):
    qa_bucket = os.environ['QA_BUCKET']
    cloudfront = os.environ['QA_CLOUDFRONT']
    report = event['report'].get('Payload')
    suite = report.get('suite_name')
    folder_key = report.get('folder_key')
    validate_id = report.get('validate_id')
    link,key = create_json_report(suite,cloudfront,folder_key,validate_id)
    os.system("chmod +x generate_report.sh")
    os.system(f"sh generate_report.sh {key} {qa_bucket}")

    return link
