from pathlib import Path
from great_expectations.data_context import EphemeralDataContext
from great_expectations.checkpoint import SimpleCheckpoint
BASE_DIR = Path(__file__).resolve().parent


def validate_data(file, suite_name, saved_context, data_asset):
    context_ge = saved_context
    expectation_suite_name = suite_name
    batch_request = data_asset.build_batch_request()
    checkpoint_config = {
        "class_name": "SimpleCheckpoint",
        "validations": [
            {
                "batch_request": batch_request,
                "expectation_suite_name": expectation_suite_name
            }
        ]
    }
    checkpoint = SimpleCheckpoint(
        f"_tmp_checkpoint_{expectation_suite_name}",
        context_ge,
        **checkpoint_config
    )
    results = checkpoint.run(result_format="SUMMARY", run_name=suite_name)
    validation_result_identifier = results.list_validation_result_identifiers()[
        0]

    if not results['success']:
        context_ge.build_data_docs(
            site_names='s3_site',
            resource_identifiers=[validation_result_identifier]
        )
    result = str(validation_result_identifier).replace(
        'ValidationResultIdentifier::', '')
    return result
