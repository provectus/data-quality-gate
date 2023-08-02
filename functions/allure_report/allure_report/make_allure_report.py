from mapper import create_json_report
import os
from loguru import logger

def handler(event, context):
    logger.info("Starting making of allure report")
    qa_bucket = os.environ['BUCKET']
    reports_web = os.environ['REPORTS_WEB']
    report = event['report'].get('Payload')
    suite = report.get('suite_name')
    folder_key = report.get('folder_key')
    validate_id = report.get('validate_id')
    link, key = create_json_report(suite, reports_web, folder_key, validate_id)
    os.system("chmod +x generate_report.sh")
    os.system(f"sh generate_report.sh {key} {qa_bucket}")
    logger.info("Making of allure report is finished")

    return link
