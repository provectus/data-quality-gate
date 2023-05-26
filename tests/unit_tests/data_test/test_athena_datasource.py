from data_source_factory import AthenaDataSource
from moto import mock_athena
import pandas as pd


class TestAthenaDataSource:
    @mock_athena
    def test_athena_datasource(self):
        athena_data_source = AthenaDataSource("test-bucket", "test_table")
        final_df, source = athena_data_source.read(
            "s3://test-bucket/test-path/test_file.csv")
        assert final_df.equals(pd.DataFrame())
        assert source == "s3://test-bucket/test-path/test_file.csv"
