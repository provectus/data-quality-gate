import datasource as ds
import pytest


@pytest.mark.parametrize("source, expected_extension", [
    ('s3://my-bucket/my-folder/my-file.csv', 'csv'),
    ('s3://my-bucket/my-folder/my-file', ''),
    ('', '')
])
def test_get_file_extension(source, expected_extension):
    assert ds.get_file_extension(source) == expected_extension


@pytest.mark.parametrize("source, extension, expected_output", [
    ("s3://my-bucket/my-folder/my-file_2022-02-14.csv", "csv", "my-file"),
    ("s3://my-bucket/my-folder/my-file.csv", "json", None),
    ("", "csv", None),
])
def test_get_source_name(source, extension, expected_output):
    assert ds.get_source_name(source, extension) == expected_output


@pytest.mark.parametrize("source, source_engine, expected_output", [
    (['file1.csv', 'file2.csv', 'file3.csv'], 'my-bucket',
        [
            's3://my-bucket/file1.csv',
            's3://my-bucket/file2.csv',
            's3://my-bucket/file3.csv'
    ]),
    ([], 'my-bucket', []),
    (['file1.csv'], 'my-bucket', ['s3://my-bucket/file1.csv']),
    (['folder1/file1.csv', 'folder2/file2.csv'], 'my-bucket',
        ['s3://my-bucket/folder1/file1.csv',
            's3://my-bucket/folder2/file2.csv'
         ]),
])
def test_concat_source_list(source, source_engine, expected_output):
    assert ds.concat_source_list(source, source_engine) == expected_output
