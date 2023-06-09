from mapper import get_test_name


def test_get_test_name():
    file = {
        "expectation_config": {
            "expectation_type": "expect_column_values_to_not_be_null",
            "kwargs": {
                "column": "age"
            }
        }
    }
    assert get_test_name(file) == "expect_column_values_to_not_be_null"
