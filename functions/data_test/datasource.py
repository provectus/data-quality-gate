import json

import numpy as np
import pandas as pd
import os
import boto3
import awswrangler as wr
import re

ENV = os.environ['ENVIRONMENT']
qa_bucket_name = os.environ['QA_BUCKET']


def concat_source_list(source, source_engine):
    final_source_files = []
    for sc in source:
        final_source_files.append(f"s3://{source_engine}/{sc}")
    return final_source_files


def get_file_extension(source):
    return source.split(".")[-1]


def read_source(source, engine, extension, run_name, table_name=None):
    path = source
    if engine == 's3':
        if extension == 'csv':
            return wr.s3.read_csv(path=source),path
        elif extension == 'parquet':
            return wr.s3.read_parquet(path=source,ignore_index=True),path
    elif engine == 'athena':
        database_name = f"{ENV}_{table_name.split('.')[0]}"
        athena_table = table_name.split('.')[-1]
        final_df = wr.athena.read_sql_query(
            sql=f"select * from {athena_table}",
            database=database_name,
            ctas_approach=False,
            s3_output=f"s3://{qa_bucket_name}/athena_results/"
        )
        return final_df, path
    elif engine == 'redshift':
        final_df = wr.s3.read_parquet(path=source, ignore_index=True)
        final_df.columns = final_df.columns.str.lower()
        if 'redshift' in run_name:
            redshift_db = os.environ['REDSHIFT_DB']
            redshift_secret = os.environ['REDSHIFT_SECRET']
            try:
                sort_keys_config = json.loads(
                    wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/sort_keys.json").to_json())
                sort_key = sort_keys_config[table_name]['sortKey']
            except KeyError:
                sort_key = ['update_dt']
            con = wr.redshift.connect(secret_id=redshift_secret, dbname=redshift_db)
            if final_df.nunique()[sort_key][0]>1:
                min_key = final_df[sort_key].min()
                max_key = final_df[sort_key].max()
                sql_query = f"SELECT * FROM public.{table_name} WHERE {sort_key[0]} between \\'{min_key}\\' and \\'{max_key}\\'"
                final_df = wr.redshift.unload(
                    sql=sql_query,
                    con=con,
                    path=f"s3://{qa_bucket_name}/redshift/{table_name}/"
                )
                con.close()
            else:
                key = str(final_df[sort_key].loc[0])
                sql_query = f"SELECT * FROM public.{table_name} WHERE {sort_key[0]}=\\'{key}\\'"
                final_df = wr.redshift.unload(
                    sql=sql_query,
                    con=con,
                    path=f"s3://{qa_bucket_name}/redshift/{table_name}/"
                )
                con.close()

        return final_df, path
    elif engine == 'hudi':
        columns_to_drop = ['_hoodie_commit_time', '_hoodie_commit_seqno', '_hoodie_record_key',
                           '_hoodie_partition_path', '_hoodie_file_name']
        pk_config = wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/pks.json")
        parquet_args = {
            'timestamp_as_object': True
        }
        df = wr.s3.read_parquet(path=source, pyarrow_additional_kwargs=parquet_args)
        try:
            primary_key = pk_config[table_name][0]
        except KeyError:
            raise KeyError('File not found in config')
        if 'transform' in run_name:
            database_name = f"{ENV}_{table_name.split('.')[0]}"
            athena_table = table_name.split('.')[-1]
            keys = df.groupby(primary_key)['dms_load_at'].max().tolist()
            data = wr.athena.read_sql_query(
                sql=f"select * from {athena_table}",
                database=database_name,
                ctas_approach=False,
                s3_output=f"s3://{qa_bucket_name}/athena_results/"
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
    elif engine == 'postgresql':
        return 5
    elif engine == 'snowflake':
        return 6
    else:
        return wr.s3.read_parquet(path=source),path


def get_source_name(source, extension):
    return re.search(f'.*/(.+?)(\_(\d.*)|).{extension}', source).group(1)


def prepare_final_ds(source, engine, source_engine, run_name, source_name=None):
    path = source
    if engine == 's3':
        source = concat_source_list(source, source_engine)
        source_extension = get_file_extension(source[0])
        df, path = read_source(source, engine, source_extension, run_name)
    elif engine == 'hudi':
        source = concat_source_list(source, source_engine)
        source_extension = get_file_extension(source[0])
        df, path = read_source(source, engine, source_extension, run_name, source_name)
    else:
        source = concat_source_list(source, source_engine)
        df, path = read_source(source, engine, None, run_name, source_name)
    return df, path
