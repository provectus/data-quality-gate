from abc import ABC, abstractmethod
import awswrangler as wr
import os
import json

ENV = os.environ['ENVIRONMENT']

class DataSourceFactory:
    
    @staticmethod
    def create_data_source(engine, qa_bucket_name, extension, run_name, table_name, coverage_config):
        if engine == 's3':
            return S3DataSource(extension)
        elif engine == 'athena':
            return AthenaDataSource(qa_bucket_name, table_name)
        elif engine == 'redshift':
            return RedshiftDataSource(qa_bucket_name, run_name, table_name, coverage_config)
        elif engine == 'hudi':
            return HudiDataSource(qa_bucket_name, run_name, table_name)
        else:
            return S3DataSource(extension)


class DataSource(ABC):
    @abstractmethod
    def read(self, source):
        pass


class S3DataSource(DataSource):
    def __init__(self, extension):
        self.extension = extension

    def read(self, source):
        if self.extension == 'csv':
            return wr.s3.read_csv(path=source), source
        elif self.extension == 'parquet':
            return wr.s3.read_parquet(path=source, ignore_index=True), source
        elif self.extension == 'json':
            try:
                return wr.s3.read_json(path=source), source
            except ValueError:
                return wr.s3.read_json(path=source, lines=True), source
        else:
            return wr.s3.read_parquet(path=source), source
        

class AthenaDataSource(DataSource):
    def __init__(self, qa_bucket_name, table_name):
        self.qa_bucket_name = qa_bucket_name
        self.table_name = table_name

    def read(self, source):
        database_name = f"{ENV}_{self.table_name.split('.')[0]}"
        athena_table = self.table_name.split('.')[-1]
        final_df = wr.athena.read_sql_query(
            sql=f"select * from {athena_table}",
            database=database_name,
            ctas_approach=False,
            s3_output=f"s3://{self.qa_bucket_name}/athena_results/"
        )
        return final_df, source


class RedshiftDataSource(DataSource):
    def __init__(self, qa_bucket_name, run_name, table_name, coverage_config):
        self.qa_bucket_name = qa_bucket_name
        self.run_name = run_name
        self.table_name = table_name
        self.coverage_config = coverage_config

    def read(self, source):
        final_df = wr.s3.read_parquet(path=source, ignore_index=True)
        final_df.columns = final_df.columns.str.lower()
        if 'redshift' in self.run_name:
            redshift_db = os.environ['REDSHIFT_DB']
            redshift_secret = os.environ['REDSHIFT_SECRET']
            try:
                sort_keys_config = json.loads(
                    wr.s3.read_json(path=f"s3://{self.qa_bucket_name}/test_configs/sort_keys.json").to_json())
                sort_key = list(map(str.lower, sort_keys_config[self.table_name]["sortKey"]))
            except KeyError:
                sort_key = ['update_dt']
            try:
                target_table = self.coverage_config["targetTable"]
            except (KeyError, IndexError, TypeError) as e:
                target_table = None
            if target_table:
                table_name = target_table
            con = wr.redshift.connect(secret_id=redshift_secret, dbname=redshift_db)
            try:
                nunique = final_df.nunique()[sort_key][0]
            except (KeyError,IndexError) as e:
                nunique = final_df.nunique()[sort_key]
            if nunique > 1:
                min_key = final_df[sort_key].min()
                max_key = final_df[sort_key].max()
                if type(min_key) != str or type(max_key) != str:
                    min_key = final_df[sort_key].min()[0]
                    max_key = final_df[sort_key].max()[0]
                sql_query = f"SELECT * FROM public.{self.table_name} WHERE {sort_key[0]} between \\'{min_key}\\' and \\'{max_key}\\'"
            else:
                key = final_df[sort_key].values[0]
                if type(key) != str:
                    key = str(key[0])
                sql_query = f"SELECT * FROM {table_name}.{table_name} WHERE {sort_key[0]}=\\'{key}\\'"
            path = f"s3://{self.qa_bucket_name}/redshift/{self.table_name}/"
            final_df = self.unload_final_df(sql_query, con, path)
        return final_df, source

    def unload_final_df(self, sql_query, con, path):
        try: 
            final_df = wr.redshift.unload(
                sql=sql_query,
                con=con,
                path=path
            )
        finally:
            con.close()
        return final_df

class HudiDataSource(DataSource):
    def __init__(self, qa_bucket_name, run_name, table_name):
        self.qa_bucket_name = qa_bucket_name
        self.run_name = run_name
        self.table_name = table_name

    def read(self, source):
        columns_to_drop = ['_hoodie_commit_time', '_hoodie_commit_seqno', '_hoodie_record_key',
                           '_hoodie_partition_path', '_hoodie_file_name']
        pk_config = wr.s3.read_json(path=f"s3://{self.qa_bucket_name}/test_configs/pks.json")
        parquet_args = {
            'timestamp_as_object': True
        }
        df = wr.s3.read_parquet(path=source, pyarrow_additional_kwargs=parquet_args)
        try:
            primary_key = pk_config[self.table_name][0]
        except KeyError:
            raise KeyError('File not found in config')
        if 'transform' in self.run_name:
            database_name = f"{ENV}_{self.table_name.split('.')[0]}"
            athena_table = self.table_name.split('.')[-1]
            keys = df.groupby(primary_key)['dms_load_at'].max().tolist()
            data = wr.athena.read_sql_query(
                sql=f"select * from {athena_table}",
                database=database_name,
                ctas_approach=False,
                s3_output=f"s3://{self.qa_bucket_name}/athena_results/"
            )
            final_df = data[data['dms_load_at'].isin(keys)].reset_index(drop=True)
            try:
                path = final_df['_hoodie_commit_time'].iloc[0]
            except IndexError:
                raise IndexError('Keys from CDC not found in HUDI table')
            final_df = final_df.drop(columns_to_drop, axis=1).reset_index(drop=True)
            return final_df, path
        else:
            keys = df.groupby(primary_key)['dms_load_at'].max().tolist()
            final_df = df[df['dms_load_at'].isin(keys)].reset_index(drop=True)
            final_df.columns = final_df.columns.str.lower()
            try:
                final_df = final_df.drop('op', axis=1).reset_index(drop=True)
            except KeyError:
                print('Op column not exist')
            return final_df, path
