import datetime
import io
import json
import os
from pathlib import Path

import awswrangler as wr
import boto3
import pandas
import pandas as pd

from datasource import get_file_extension
from datasource import get_source_name
from datasource import prepare_final_ds
from profiling import profile_data
from suite_run import validate_data

import logging
logging.getLogger().setLevel(logging.INFO)

_COLUMNS_SCHEME = ['timestamp', 'unix_time', 'sleep_stage', 'hr', 'hr_avg', 'hr_min',
                   'hr_max', 'hr_var', 'hr_var_avg', 'hr_var_min', 'hr_var_max', 'motion',
                   'resp', 'resp_avg', 'resp_min', 'resp_max', 'user_id', 'dp_id', 'st_id',
                   'sleep_score', 'sleep_efficiency', 'calculated_sleep_score',
                   'calculated_sleep_efficiency', 'continuous_sleep_score',
                   'continuous_sleep_efficiency', 'start_time', 'json_path',
                   'temperature_fahrenheit', 'humidity', 'set_from', 'set_to',
                   'water_from', 'water_to', 'sleep_stage_encode']

def load_dataframe(data_capture_uri, interval):
    start_time = datetime.datetime.now() - datetime.timedelta(hours=1)
    end_time = start_time - datetime.timedelta(hours=interval - 1)

    boto3_session = boto3.Session()

    data_range = pandas.date_range(end_time, start_time, freq="1h")
    data_ranges = [
        os.path.join(data_capture_uri, f"{x.year}/{x.strftime('%m')}/{x.strftime('%d')}/{x.strftime('%H')}") for x in
        data_range]
    files = []

    logging.info(logging.info(f"Data ranges: {data_ranges}"))
    for x in data_ranges:
        files.extend(wr.s3.list_objects(x, boto3_session=boto3_session))

    logging.info(f"Files to read as json: {files}")
    if len(files) == 0:
        return pd.DataFrame(columns=_COLUMNS_SCHEME)

    report = wr.s3.read_json(files, boto3_session=boto3_session, use_threads=True, lines=True)
    data_list = [x["endpointInput"]["data"] for x in report["captureData"]]

    df = pd.DataFrame()
    for x in data_list:
        df = df.append(pd.read_csv(io.StringIO(x), header=None, index_col=False, names=_COLUMNS_SCHEME))

    return df


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
    coverage_config = json.loads(
        s3.Object(qa_bucket_name, "test_configs/test_coverage.json").get()['Body'].read().decode('utf-8'))

    if type(source_input) is not list:
        source = [source_input]
    else:
        source = source_input
    try:
        source_name = event['table']
    except KeyError:
        source_extension = get_file_extension(source[0])
        source_name = get_source_name(source[0], engine, source_extension)

    suite_name = f"{source_name}_{run_name}"

    try:
        source_covered = coverage_config[suite_name]['complexSuite']
    except (IndexError, KeyError) as e:
        source_covered = False

    logging.info(f"Source covered: {source_covered}")

    if not source_covered:
        final_ds, path = prepare_final_ds(source, engine, source_root, run_name, source_name)
    else:
        data_capture_uri = os.path.join("s3://", source_root, source[0])
        interval = int(event['interval'])
        path = engine
        final_ds = load_dataframe(data_capture_uri, interval)


    profile_link, folder_key, config = profile_data(final_ds, suite_name, cloudfront, source_root, source_covered, {},
                                                    run_name)
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
