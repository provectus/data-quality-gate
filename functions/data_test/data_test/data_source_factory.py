from abc import ABC, abstractmethod
import awswrangler as wr
import os
import json
from loguru import logger
ENV = os.environ['ENVIRONMENT']


class DataSourceFactory:

    @staticmethod
    def create_data_source(
            engine,
            qa_bucket_name,
            extension,
            run_name,
            table_name,
            coverage_config):
        if engine == 's3':
            return S3DataSource(extension)
        elif engine == 'athena':
            return AthenaDataSource(qa_bucket_name, table_name)
        elif engine == 'redshift':
            return RedshiftDataSource(
                qa_bucket_name, run_name, table_name, coverage_config)
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
        logger.info("DataSource is s3")
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
        logger.info("DataSource is Athena")
        return final_df, source


class RedshiftDataSource(DataSource):
    def __init__(self, qa_bucket_name, run_name, table_name, coverage_config):
        self.qa_bucket_name = qa_bucket_name
        self.run_name = run_name
        self.table_name = table_name
        self.coverage_config = coverage_config

    def read(self, source):
        logger.info("DataSource is Redshift")
        final_df = wr.s3.read_parquet(path=source, ignore_index=True)
        final_df.columns = final_df.columns.str.lower()
        if 'redshift' in self.run_name:
            redshift_db = os.environ['REDSHIFT_DB']
            redshift_secret = os.environ['REDSHIFT_SECRET']
            logger.debug("self.run_name contains redshift")
            try:
                sort_keys_config = json.loads(wr.s3.read_json(
                    path=f"s3://{self.qa_bucket_name}/test_configs/sort_keys.json").to_json())
                sort_key = list(map(str.lower,
                                    sort_keys_config[self.table_name]["sortKey"]))
                logger.debug(f"sort_key was found for {self.table_name} at sort_keys.json")
            except KeyError:
                sort_key = ['update_dt']
                logger.warning(f"sort_key was not found for {self.table_name} at sort_keys.json and set to update_dt")
            try:
                target_table = self.coverage_config["targetTable"]
                logger.debug("targetTable was found at test_coverage.json")
            except (KeyError, IndexError, TypeError) as e:
                target_table = None
                logger.warning("targetTable was not found at test_coverage.json and set to None")
            if target_table:
                table_name = target_table
                logger.debug("targetTable is exist")
            con = wr.redshift.connect(
                secret_id=redshift_secret, dbname=redshift_db)
            try:
                nunique = final_df.nunique()[sort_key][0]
                logger.debug("nunique is appear multiple time")
            except (KeyError, IndexError) as e:
                nunique = final_df.nunique()[sort_key]
                logger.debug("nunique is appear once time")
            if nunique > 1:
                logger.debug("nunique>1")
                min_key = final_df[sort_key].min()
                max_key = final_df[sort_key].max()
                if not isinstance(
                        min_key,
                        str) or not isinstance(
                        max_key,
                        str):
                    min_key = final_df[sort_key].min()[0]
                    max_key = final_df[sort_key].max()[0]
                    logger.debug("min and max key are not str")
                sql_query = f"SELECT * FROM public.{self.table_name} WHERE {sort_key[0]} between \\'{min_key}\\' and \\'{max_key}\\'"
            else:
                logger.debug("min and max key are str")
                key = final_df[sort_key].values[0]
                if not isinstance(key, str):
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
        path = source
        columns_to_drop = [
            '_hoodie_commit_time',
            '_hoodie_commit_seqno',
            '_hoodie_record_key',
            '_hoodie_partition_path',
            '_hoodie_file_name']
        pk_config = wr.s3.read_json(
            path=f"s3://{self.qa_bucket_name}/test_configs/pks.json")
        parquet_args = {
            'timestamp_as_object': True
        }
        df = wr.s3.read_parquet(path=source,
                                pyarrow_additional_kwargs=parquet_args)
        try:
            primary_key = pk_config[self.table_name][0]
            logger.debug(f"pk key for {self.table_name} was found at pks.json")
        except KeyError:
            logger.error(f"pk key for {self.table_name} was not found at pks.json and we can't process "
                         f"transform part for this file")
            raise KeyError('File not found in config')
        if 'transform' in self.run_name:
            logger.debug("self.run_name contains transform")
            database_name = f"{ENV}_{self.table_name.split('.')[0]}"
            athena_table = self.table_name.split('.')[-1]
            keys = df.groupby(primary_key)['dms_load_at'].max().tolist()
            data = wr.athena.read_sql_query(
                sql=f"select * from {athena_table}",
                database=database_name,
                ctas_approach=False,
                s3_output=f"s3://{self.qa_bucket_name}/athena_results/"
            )
            final_df = data[data['dms_load_at'].isin(
                keys)].reset_index(drop=True)
            try:
                path = final_df['_hoodie_commit_time'].iloc[0]
                logger.debug("Keys from CDC was found at HUDI table")
            except IndexError:
                logger.error("Keys from CDC was not found at HUDI table")
                raise IndexError('Keys from CDC not found in HUDI table')
            final_df = final_df.drop(
                columns_to_drop,
                axis=1).reset_index(
                drop=True)
            return final_df, path
        else:
            logger.debug("self.run_name not contains transform")
            keys = df.groupby(primary_key)['dms_load_at'].max().tolist()
            final_df = df[df['dms_load_at'].isin(keys)].reset_index(drop=True)
            final_df.columns = final_df.columns.str.lower()
            try:
                final_df = final_df.drop('op', axis=1).reset_index(drop=True)
                logger.debug("Op column is exist")
            except KeyError:
                logger.warning("Op column is not exist")
            return final_df, path
