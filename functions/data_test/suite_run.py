from pathlib import Path
from great_expectations.data_context import BaseDataContext
BASE_DIR = Path(__file__).resolve().parent


def validate_data(file, suite_name, config):
    context_ge = BaseDataContext(project_config=config)

    expectation_suite_name = suite_name
    batch_kwargs = {'dataset': file,
                    'datasource': "pandas_s3",
                    'data_asset_name': expectation_suite_name}
    batch = context_ge.get_batch(
        batch_kwargs=batch_kwargs,
        expectation_suite_name=expectation_suite_name
    )
    results = context_ge.run_validation_operator(
        "action_list_operator", assets_to_validate=[batch])
    identifiers = results.list_validation_result_identifiers()
    validation_result_identifier = identifiers[0]
    if (not results['success']):
        context_ge.build_data_docs(
            site_names='s3_site',
            resource_identifiers=[validation_result_identifier]
        )
    result = str(validation_result_identifier).replace(
        'ValidationResultIdentifier::', '')
    return result
