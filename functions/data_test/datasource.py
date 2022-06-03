import numpy as np
import pandas as pd
import os
import boto3
import awswrangler as wr
import re

def concat_source_list(engine,source,source_engine):
    final_source_files = []
    match engine:
        case 's3':
            for sc in source:
                final_source_files.append(source_engine + '/' + sc.split('/')[0] + sc.replace(sc.split('/')[0],''))
            return final_source_files
        case 'athena':
            return 2
        case 'redshift':
            return 2
        case 'hudi':
            return 3
        case 'postgresql':
            return 4
        case 'snowflake':
            return 4
        case _:
            for sc in source:
                final_source_files.append(source_engine + '/' + sc.split('/')[0] + sc.replace(sc.split('/')[0], ''))
            return final_source_files

def prepare_source(engine,source,source_engine):
    match engine:
        case 's3':
            return source_engine + '/' + source.split('/')[0] + source.replace(source.split('/')[0],'')
        case 'athena':
            return 2
        case 'redshift':
            return 2
        case 'hudi':
            return 3
        case 'postgresql':
            return 4
        case 'snowflake':
            return 4
        case _:
            return source_engine + '/' + source.split('/')[0] + source.replace(source.split('/')[0],'')


def read_source(source,engine):
    match engine:
        case 's3':
            return wr.s3.read_parquet(path=source)
        case 'athena':
            return 2
        case 'redshift':
            return 2
        case 'hudi':
            return 3
        case 'postgresql':
            return 4
        case 'snowflake':
            return 4
        case _:
            return wr.s3.read_parquet(path=source)



def get_source_name(source,engine):
    match engine:
        case 's3':
            if type(source) == list:
                source_name = re.search('.*/(.+?)\\.parquet', source[0]).group(1)
            else:
                source_name = re.search('.*/(.+?)\\.parquet', source).group(1)
            return source_name
        case 'athena':
            return 2
        case 'redshift':
            return 2
        case 'hudi':
            return 3
        case 'postgresql':
            return 4
        case 'snowflake':
            return 4
        case _:
            if type(source) == list:
                source_name = re.search('.*/(.+?)\\.parquet', source[0]).group(1)
            else:
                source_name = re.search('.*/(.+?)\\.parquet', source).group(1)
            return source_name

def prepare_final_ds(source,engine,source_engine):

    if type(source) == list:
        source = concat_source_list(source,engine,source_engine)
        source_name = get_source_name(source,engine)
    else:
        source = prepare_source(source,engine,source_engine)
        source_name = get_source_name(source,engine)
    df = read_source(source,engine)

    return df,source_name
