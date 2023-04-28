import pandas as pd
import moto
import boto3
import pytest
from functions.data_test.data_source_factory import RedshiftDataSource
import awswrangler as wr
from unittest.mock import patch


class TestRedshiftDataSource:
    @pytest.fixture(scope="function")
    def moto_s3(self):
        with moto.mock_s3():
            s3 = boto3.resource("s3", region_name="us-east-1")
            s3.create_bucket(
                Bucket="dataqa",
            )
            yield s3

    # emulate data in s3
    @pytest.fixture(scope="function")
    def upload_files(self,
                     moto_s3):
        df = pd.DataFrame(
            {"PassengerId": [10, 20, 30], "update_dt": [40, 50, 60]})
        path = 's3://dataqa/titanic.parquet'
        wr.s3.to_parquet(df=df, path=path)

    @pytest.fixture(scope="function")
    def upload_sort_keys(self,
                         moto_s3):
        sort_key_json = """
      {
        "titanic": {
          "sortKey": [
            "PassengerId"
          ]
        }
      }
      """
        df = pd.read_json(sort_key_json)
        path = "s3://dataqa/test_configs/sort_keys.json"
        wr.s3.to_json(df=df, path=path)

    # emulate data in redshift
    @pytest.fixture(scope="function")
    def create_upload_files(self,
                            moto_s3):
        df = pd.DataFrame({"passengerid": [1, 2, 3], "update_dt": [4, 5, 6]})
        path = 's3://dataqa/redshift/titanic.parquet/temp.parquet'
        wr.s3.to_parquet(df=df, path=path)

    def test_read_not_redshift_in_run_name(self,
                                           upload_files):
        redshift_data_source = RedshiftDataSource(
            "dataqa", "test_", "titanic.parquet", "coverage.json")
        final_df, source = redshift_data_source.read(
            "s3://dataqa/titanic.parquet")
        assert len(final_df.index) == 3
        assert source == "s3://dataqa/titanic.parquet"
        expected_df = pd.DataFrame(
            {"passengerid": [10, 20, 30], "update_dt": [40, 50, 60]})
        pd.testing.assert_frame_equal(final_df,
                                      expected_df,
                                      check_dtype=False)

    def test_unload_final_df(self,
                             create_upload_files):
        with patch('awswrangler.redshift.connect') as mock_connect:
            mock_con = mock_connect.return_value.__enter__.return_value
            mock_con.cursor.return_value.fetchall.return_value = [
                (1, 2), (3, 4)]
            final_df = RedshiftDataSource("dataqa",
                                          "test_",
                                          "titanic.parquet",
                                          "coverage.json").unload_final_df(
                'SELECT * FROM mytable', mock_con, 's3://dataqa/')
            expected_df = pd.DataFrame(
                {"passengerid": [1, 2, 3], "update_dt": [4, 5, 6]})
            pd.testing.assert_frame_equal(
                final_df,
                expected_df,
                check_dtype=False)

    def test_read_redshift_in_run_name(self,
                                       upload_sort_keys,
                                       upload_files,
                                       create_upload_files):
        with patch('awswrangler.redshift.connect') as mock_connect:
            mock_con = mock_connect.return_value.__enter__.return_value
            mock_con.cursor.return_value.fetchall.return_value = [
                (1, 2), (3, 4)]
            redshift_data_source = RedshiftDataSource(
                "dataqa", "test_redshift", "titanic.parquet", "coverage.json")
            final_df, source = redshift_data_source.read(
                "s3://dataqa/titanic.parquet")
            assert len(final_df.index) == 3
            expected_df = pd.DataFrame(
                {"passengerid": [1, 2, 3], "update_dt": [4, 5, 6]})
            pd.testing.assert_frame_equal(
                final_df,
                expected_df,
                check_dtype=False)
            assert source == "s3://dataqa/titanic.parquet"
