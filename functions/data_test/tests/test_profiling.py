import pytest
from profiling import (add_local_s3_to_stores,
                       read_gx_config_file,
                       expectations_unique,
                       expectations_null,
                       expectations_mean,
                       calculate_mean)
import great_expectations as gx
import pandas as pd

ENDPOINT_URL = "http://localhost:4566"
summary_template = {
    "n_distinct": 418,
    "p_distinct": 1.0,
    "is_unique": True,
    "n_unique": 418,
    "p_unique": 1.0,
    "type": "Numeric",
    "hashable": True,
    "value_counts_without_nan": "892",
    "value_counts_index_sorted": "892     1 \nName: PassengerId, Length: 418, dtype: int64",
    "ordering": True,
    "n_missing": 0,
    "n": 418,
    "p_missing": 0.0,
    "count": 418,
    "memory_size": 3472,
    "n_negative": "0",
    "p_negative": 0.0,
    "n_infinite": "0",
    "n_zeros": 0,
    "mean": 1100.5,
    "std": 120.81045760473994,
    "variance": 14595.166666666666,
    "min": "892",
    "max": "1309",
    "kurtosis": -1.2,
    "skewness": 0.0,
    "sum": "460009",
    "mad": 104.5,
    "range": "417",
    "5%": 912.85,
    "25%": 996.25,
    "50%": 1100.5,
    "75%": 1204.75,
    "95%": 1288.15,
    "iqr": 208.5,
    "cv": 0.1097777897362471,
    "p_zeros": 0.0,
    "p_infinite": 0.0,
    "monotonic_increase": True,
    "monotonic_decrease": False,
    "monotonic_increase_strict": True,
    "monotonic_decrease_strict": False,
    "monotonic": 2,
    "histogram": ["[9]"]
}


@pytest.mark.parametrize("stores, expected_output", [
    ({"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket"}}},
     {"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket",
                                   "boto3_options":
                                       {"endpoint_url": ENDPOINT_URL}}}}),
    ({}, {})
])
def test_add_local_s3_to_stores(stores, expected_output):
    assert add_local_s3_to_stores(stores, ENDPOINT_URL) == expected_output


def test_gx_config_file():
    config_file = read_gx_config_file()
    assert config_file["config_version"] == 2.0


def test_gx_config_file_path_is_not_none(tmpdir):
    p = tmpdir.mkdir("config").join("great_expectations.yml")
    p.write("config_version: 10.0")
    config_file = read_gx_config_file(path=p)
    assert config_file["config_version"] == 10.0


def change_template(params, params_name):
    name_expected = "PassengerId"
    summary_expected = summary_template
    for param, name in zip(params, params_name):
        summary_expected[name] = param
    return name_expected, summary_expected


@pytest.fixture(autouse=True)
def before_and_after_test():
    df = pd.DataFrame(columns=['PassengerId'])
    context_gx = gx.get_context()
    datasource = context_gx.sources.add_pandas(name="test")
    data_asset = datasource.add_dataframe_asset(name="test")
    batch_request = data_asset.build_batch_request(dataframe=df)
    context_gx.add_or_update_expectation_suite("test_suite")
    batch_empty = context_gx.get_validator(
        batch_request=batch_request,
        expectation_suite_name="test_suite",
    )

    yield batch_empty

    context_gx.delete_expectation_suite("test_suite")
    context_gx.delete_datasource("test")


@pytest.mark.parametrize("p_unique, applied", [(0.95, True), (0.9, True), (0.1, False)])
def test_expectations_unique(p_unique, applied, before_and_after_test):
    p_unique = eval("p_unique")
    applied = eval("applied")
    name_expected, summary_expected = change_template([p_unique], ["p_unique"])
    expectation_type = "expect_column_values_to_be_unique"
    batch_empty = before_and_after_test

    name, summary, batch = expectations_unique(name_expected, summary_expected, batch_empty)

    assert name == name_expected
    assert "expect_column_to_exist" in str(batch.expectation_suite)
    assert (expectation_type in str(batch.expectation_suite)) == applied


@pytest.mark.parametrize("p_missing, applied", [(0.4, True), (0.2, True), (0.5, False)])
def test_expectations_null(p_missing, applied, before_and_after_test):
    p_missing = eval("p_missing")
    applied = eval("applied")
    name_expected, summary_expected = change_template([p_missing], ["p_missing"])
    expectation_type = "expect_column_values_to_not_be_null"
    batch_empty = before_and_after_test

    name, summary, batch = expectations_null(name_expected, summary_expected, batch_empty)

    assert name == name_expected
    assert (expectation_type in str(batch.expectation_suite)) == applied


@pytest.mark.parametrize("n,std,mean,max_mean,min_mean",
                         [(418, 120.81045760473994, 1100.5, 1106.349942307408, 1094.650057692592)])
def test_expectations_mean(n, std, mean, max_mean, min_mean, before_and_after_test):
    n = eval("n")
    std = eval("std")
    mean = eval("mean")
    max_mean_expected = eval("max_mean")
    min_mean_expected = eval("min_mean")
    name_expected, summary_expected = change_template([n, std, mean], ["n", "std", "mean"])
    expectation_type = "expect_column_mean_to_be_between"
    batch_empty = before_and_after_test

    min_mean, max_mean = calculate_mean(summary_expected)
    name, summary, batch = expectations_mean(name_expected, summary_expected, batch_empty)

    assert (min_mean == min_mean_expected and max_mean == max_mean_expected)
    assert name == name_expected
    assert expectation_type in str(batch.expectation_suite)
