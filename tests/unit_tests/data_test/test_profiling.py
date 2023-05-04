import pytest
from functions.data_test.profiling import (add_local_s3_to_stores)


@pytest.mark.parametrize("stores, expected_output", [
    ({"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket"}}},
     {"store1": {"store_backend": {"type": "s3", "bucket": "my-bucket", "boto3_options": {"endpoint_url": "http://localhost:4566"}}}}),
    ({}, {})
])
def test_add_local_s3_to_stores(stores, expected_output):
    endpoint_url = "http://localhost:4566"
    assert add_local_s3_to_stores(stores, endpoint_url) == expected_output
