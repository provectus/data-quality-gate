from .profiling import profile_data
from .suite_run import validate_data
import os
import s3fs
import re
import boto3
import awswrangler as wr
import json
from .datasource import prepare_final_ds
from .datasource import get_source_name
from .datasource import get_file_extension


def handler(event, context):
    s3 = boto3.resource('s3')
    cloudfront = os.environ['QA_CLOUDFRONT']
    qa_bucket_name = os.environ['QA_BUCKET']
    run_name = event['run_name']
    if 'engine' in event:
        engine = event['engine']
    else:
        pipeline_config = json.loads(
            wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/pipeline.json").to_json())
        engine = pipeline_config[run_name]['engine']
    source_root = event['source_root']
    source_input = event['source_data']
    # coverage_config = json.loads(s3.Object(qa_bucket_name,"test_configs/test_coverage.json" ).get()['Body'].read().decode('utf-8'))
    coverage_config = json.loads(wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/test_coverage.json").to_json())
    mapping_config = json.loads(wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/mapping.json").to_json())
    if type(source_input) is not list:
        source = [source_input]
    else:
        source = source_input
    if event.get('table'):
        source_name = event['table']
    else:
        source_extension = get_file_extension(source[0])
        source_name = get_source_name(source[0], source_extension)
    final_ds, path = prepare_final_ds(source, engine, source_root, run_name, source_name)
    suite_name = f"{source_name}_{run_name}"
    try:
        source_covered = coverage_config[suite_name]['complexSuite']
    except (IndexError, KeyError) as e:
        source_covered = False

    profile_link, folder_key, config = profile_data(final_ds, suite_name, cloudfront, source_root, source_covered, mapping_config, run_name)
    validate_id = validate_data(final_ds, suite_name, config)
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
    return report
