from profiling import profile_data
from suite_run import validate_data
import os
import boto3
import awswrangler as wr
import json
from datasource import prepare_final_ds, get_source_name, get_file_extension
from loguru import logger


def handler(event, context):
    logger.info("Starting data test")
    if os.environ['ENVIRONMENT'] == 'local':
        endpoint_url = (f"http://{os.environ['S3_HOST']}:"
                        f"{os.environ['S3_PORT']}")
        s3 = boto3.resource("s3", endpoint_url=endpoint_url)
        wr.config.s3_endpoint_url = endpoint_url
        logger.debug("ENVIRONMENT is local")
    else:
        s3 = boto3.resource("s3")
        logger.debug("ENVIRONMENT is cloud")
    cloudfront = os.environ['REPORTS_WEB']
    qa_bucket_name = os.environ['BUCKET']
    run_name = event['run_name']
    if 'engine' in event:
        engine = event['engine']
        logger.debug("engine was found at input")
    else:
        config_file = wr.s3.read_json(
            path=f"s3://{qa_bucket_name}/test_configs/pipeline.json").to_json()
        pipeline_config = json.loads(config_file)
        engine = pipeline_config[run_name]["engine"]
        logger.debug("engine was not found at input, but in confing file")
    source_root = event["source_root"]
    source_input = event["source_data"]
    coverage_config = json.loads(
        s3.Object(qa_bucket_name, "test_configs/test_coverage.json")
        .get()["Body"].read().decode("utf-8"))
    mapping_config = json.loads(
        s3.Object(qa_bucket_name, "test_configs/mapping.json").get()["Body"]
        .read().decode("utf-8"))
    if not isinstance(source_input, list):
        source = [source_input]
        logger.debug("source_input is not list")
    else:
        source = source_input
        logger.debug("source_input is list")
    if event.get('table'):
        source_name = event['table']
        logger.debug("input contains table name")
    else:
        source_extension = get_file_extension(source[0])
        source_name = get_source_name(source[0], source_extension)
        logger.debug("input not contains table name")
    suite_name = f"{source_name}_{run_name}"
    try:
        source_covered = coverage_config[suite_name]['complexSuite']
        logger.debug(f"complexSuite param for {suite_name} was found at test_coverage.json")
    except (IndexError, KeyError):
        source_covered = False
        logger.warning(f"complexSuite param for {suite_name} was not found at test_coverage.json and set to False")
    try:
        suite_coverage_config = coverage_config[suite_name]
        logger.debug(f" {suite_name} was found at test_coverage.json")
    except (IndexError, KeyError):
        suite_coverage_config = None
        logger.warning(f" {suite_name} was not found at test_coverage.json and set to None")

    final_ds, path = prepare_final_ds(source, engine, source_root, run_name,
                                      source_name, suite_coverage_config)

    profile_link, folder_key, saved_context, data_asset = profile_data(
        final_ds, suite_name, cloudfront, source_root, source_covered, mapping_config, run_name)
    validate_id = validate_data(
        final_ds,
        suite_name,
        saved_context,
        data_asset)
    test_suite = f"{cloudfront}/data_docs/validations/{validate_id}.html"

    report = {
        "path": path,
        "file": source_name,
        "profiling": profile_link,
        "test_suite": test_suite,
        "suite_name": suite_name,
        "folder_key": folder_key,
        "run_name": run_name,
        "validate_id": validate_id
    }
    logger.info("Data test is finished successfully")
    return report
