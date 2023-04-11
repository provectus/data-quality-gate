from mapper import create_json_report
import os


def handler(event, context):
    qa_bucket = os.environ['BUCKET']
    reports_web = os.environ['REPORTS_WEB']
    report = event['report'].get('Payload')
    suite = report.get('suite_name')
    folder_key = report.get('folder_key')
    validate_id = report.get('validate_id')
    link, key = create_json_report(suite, reports_web, folder_key, validate_id)
    os.system("chmod +x generate_report.sh")
    os.system(f"sh generate_report.sh {key} {qa_bucket}")

    return link
