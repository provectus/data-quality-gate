import datasource as ds


def test_get_file_extension():
    source = 's3://my-bucket/my-folder/my-file.csv'
    extension = ds.get_file_extension(source)
    assert extension == 'csv'


def test_get_source_name_valid_source():
    source = "s3://my-bucket/my-folder/my-file_2022-02-14.csv"
    extension = "csv"
    expected_output = "my-file"
    assert ds.get_source_name(source, extension) == expected_output


def test_get_source_name_no_match():
    source = "s3://my-bucket/my-folder/my-file.csv"
    extension = "json"
    expected_output = None
    assert ds.get_source_name(source, extension) == expected_output


def test_get_source_name_empty_source():
    source = ""
    extension = "csv"
    expected_output = None
    assert ds.get_source_name(source, extension) == expected_output
