import pytest
from functions.data_test.profiling import (add_local_s3_to_stores,
                                           read_gx_config_file)


@pytest.mark.parametrize("stores, expected_output", [
    ({"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket"}}},
     {"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket",
                                   "boto3_options":
                                   {"endpoint_url": "http://localhost:4566"}
                                   }}}),
    ({}, {})
])
def test_add_local_s3_to_stores(stores, expected_output):
    endpoint_url = "http://localhost:4566"
    assert add_local_s3_to_stores(stores, endpoint_url) == expected_output


def test_gx_config_file():
    config_file = read_gx_config_file()
    assert config_file["config_version"] == 2.0


def test_gx_config_file_path_is_not_none(tmpdir):
    p = tmpdir.mkdir("config").join("great_expectations.yml")
    p.write("config_version: 10.0")
    config_file = read_gx_config_file(path=p)
    assert config_file["config_version"] == 10.0
