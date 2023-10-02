from jsonschema import validate
import pytest
import json
import os
import test_utils as test_utils

schema = {
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
        "path": {
            "type": "array",
            "items": [
                {
                    "type": "string"
                }
            ]
        },
        "file": {
            "type": "string"
        },
        "profiling": {
            "type": "string"
        },
        "test_suite": {
            "type": "string"
        },
        "suite_name": {
            "type": "string"
        },
        "folder_key": {
            "type": "string"
        },
        "run_name": {
            "type": "string"
        },
        "validate_id": {
            "type": "string"
        }
    },
    "required": [
        "path",
        "file",
        "profiling",
        "test_suite",
        "suite_name",
        "folder_key",
        "run_name",
        "validate_id"
    ]
}


@pytest.fixture
def run_lambda(request):
    bucket_name = "dataqa"
    file_name = request.param
    file_path = f"{bucket_name}/{file_name}"
    s3 = test_utils.create_boto_s3_resource()
    test_utils.upload_file_to_s3(s3, bucket_name, file_path, file_name)
    response = test_utils.invoke_lambda(file_path)
    json_response = json.loads(response.text)
    yield json_response
    test_utils.delete_s3_file(s3, bucket_name, file_path)


@pytest.mark.parametrize("run_lambda",
                         ["titanic.csv",
                          "titanic.parquet",
                          "titanic.json",
                          "titanic_nested.json"],
                         indirect=True)
def test_data_test(run_lambda: str):
    json_response = run_lambda
    validate(instance=json_response, schema=schema)


@pytest.mark.parametrize("run_lambda", ['titanic.csv'], indirect=True)
def test_profile_result_check(run_lambda: str):
    qa_bucket = os.environ['BUCKET']
    gx_dir = "great_expectations/expectations"
    s3 = test_utils.create_boto_s3_resource()
    json_response = run_lambda
    suite_name = json_response['suite_name']
    result_path = f"{qa_bucket}/{gx_dir}/{suite_name}.json"
    expectations_suite = test_utils.read_json_file(s3, qa_bucket, result_path)
    expectations = expectations_suite["expectations"]
    expectations_type = [e['expectation_type'] for e in expectations]
    assert set(expectations_type) == {
        'expect_column_values_to_be_in_type_list',
        'expect_column_value_z_scores_to_be_less_than',
        'expect_column_values_to_be_unique',
        'expect_table_columns_to_match_set',
        'expect_column_mean_to_be_between',
        'expect_column_values_to_be_between',
        'expect_column_stdev_to_be_between',
        'expect_column_to_exist',
        'expect_column_values_to_be_increasing',
        'expect_column_median_to_be_between',
        'expect_column_values_to_be_in_set',
        'expect_column_quantile_values_to_be_between',
        'expect_table_row_count_to_equal',
        'expect_column_values_to_not_be_null'}
    assert len(expectations) == 73

