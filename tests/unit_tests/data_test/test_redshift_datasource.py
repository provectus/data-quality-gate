import pandas as pd
import moto
import boto3
import pytest
from functions.data_test.data_source_factory import RedshiftDataSource
import awswrangler as wr


class TestRedshiftDataSource:
    @pytest.fixture(scope="function")
    def moto_s3(self):
      with moto.mock_s3():
          s3 = boto3.resource("s3", region_name="us-east-1")
          s3.create_bucket(
              Bucket="dataqa",
          )
          yield s3

    def test_read_not_redshift_in_run_name(self, moto_s3):
      df = pd.DataFrame({"a": [1, 2, 3], "b": [4, 5, 6]})
      path = 's3://dataqa/titanic.parquet'
      wr.s3.to_parquet(df=df, path=path)
      redshift_data_source = RedshiftDataSource("dataqa","test_", "titanic.parquet","coverage.json")
      final_df, source = redshift_data_source.read("s3://dataqa/titanic.parquet")
      assert len(final_df.index) == 3
      assert source == "s3://dataqa/titanic.parquet"