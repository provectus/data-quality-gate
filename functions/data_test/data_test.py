from profiling import profile_data
from suite_run import validate_data
import boto3
import awswrangler as wr
from datasource import prepare_final_ds
def handler(event,context):
    cloudfront = os.environ['QA_CLOUDFRONT']
    engine = event['engine']
    source_root = event['source_root']
    source = event['source_data']
    run_name = event['run_name']
    qa_bucket_name = os.environ['QA_BUCKET']
    coverage_config = wr.s3.read_json(path='s3://' + qa_bucket_name + '/test_configs/test_coverage.json')
    try:
        source_name = event['table']
    except KeyError:
        source_name = ''
    final_ds, source_name = prepare_final_ds(source, engine, source_root,source_name)
    try:
        source_covered = coverage_config[coverage_config['table'] == source_name]['complexSuite'].values[0]
    except (IndexError,KeyError) as e:
        source_covered = False

    profile_link,folder_key,config = profile_data(final_ds,source_name,cloudfront,source_root,source_covered, engine)
    validate_id = validate_data(final_ds, source_name, source_root, config)
    test_suite = cloudfront + '/data_docs/validations/' + validate_id + '.html'

    report = {
        "path": source,
        "file": source_name,
        "profiling": profile_link,
        "test_suite": test_suite,
        "suite_name": source_name,
        "folder_key": folder_key,
        "run_name": run_name,
        "validate_id": validate_id
    }

    return report
