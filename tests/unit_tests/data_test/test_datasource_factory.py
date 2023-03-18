import pytest
from functions.data_test.data_source_factory import (
    DataSourceFactory,
    S3DataSource,
    HudiDataSource,
    AthenaDataSource,
    RedshiftDataSource)


class TestDataSourceFactory:
    @pytest.mark.parametrize(
        "engine, expected_class",
        [
            ("s3", S3DataSource),
            ("hudi", HudiDataSource),
            ("athena", AthenaDataSource),
            ("redshift", RedshiftDataSource),
            ("test", S3DataSource)
        ]
    )
    def test_create_data_source(self, engine, expected_class):
        data_source = DataSourceFactory.create_data_source(engine, 
                                                           qa_bucket_name="test_qa_bucket", 
                                                           extension="test_extension", 
                                                           run_name="test_run_name", 
                                                           table_name="test_table_name")
        assert isinstance(data_source, expected_class)
