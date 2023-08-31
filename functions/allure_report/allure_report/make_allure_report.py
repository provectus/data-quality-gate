from mapper import create_json_report
from cloudpathlib import CloudPath
import os
import subprocess
import json


def handler(event, context):
    qa_bucket = os.environ['BUCKET']
    reports_web = os.environ['REPORTS_WEB']
    report = event['report'].get('Payload', event['report'])
    suite = report.get('suite_name')
    folder_key = report.get('folder_key')
    validate_id = report.get('validate_id')
    link, path = create_json_report(suite, reports_web, folder_key, validate_id)

    temp_results_path = "/tmp/result"
    allure_report_path = "/tmp/allure-report"

    results = CloudPath(f"s3://{qa_bucket}/allure/{path}/result")
    results.download_to(temp_results_path)

    subprocess.run(['allure/allure-2.14.0/bin/allure', 'generate', temp_results_path, '--clean', '-o', allure_report_path])

    results = CloudPath(f"s3://{qa_bucket}/allure/{path}/allure-report")
    results.upload_from(allure_report_path)

    if os.getenv("EXEC_ENGINE") == "argo_workflow":
        with open("/tmp/allure_report.json", "w") as outfile:
            json.dump({'link': link}, outfile)


    return link
