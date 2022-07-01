import numpy as np
import pandas as pd
import os
import boto3
import awswrangler as wr
import re

def concat_source_list(engine,source,source_engine):
    final_source_files = []
    if engine == 's3':
        for sc in source:
            final_source_files.append(source_engine + '/' + sc.split('/')[0] + sc.replace(sc.split('/')[0], ''))
        return final_source_files
    elif engine == 'athena':
        return 2
    elif engine == 'redshift':
        return 3
    elif engine == 'hudi':
        return 4
    elif engine == 'postgresql':
        return 5
    elif engine == 'snowflake':
        return 6
    else:
        for sc in source:
            final_source_files.append(source_engine + '/' + sc.split('/')[0] + sc.replace(sc.split('/')[0], ''))
        return final_source_files

def prepare_source(engine,source,source_engine):
    if engine == 's3':
        return source_engine + '/' + source.split('/')[0] + source.replace(source.split('/')[0],'')
    elif engine == 'athena':
        return 2
    elif engine == 'redshift':
        return 3
    elif engine == 'hudi':
        return 4
    elif engine == 'postgresql':
        return 5
    elif engine == 'snowflake':
        return 6
    else:
        return source_engine + '/' + source.split('/')[0] + source.replace(source.split('/')[0],'')

def read_source(source,engine):
    if engine == 's3':
        return wr.s3.read_parquet(path=source)
    elif engine == 'athena':
        return 2
    elif engine == 'redshift':
        return 3
    elif engine == 'hudi':
        return 4
    elif engine == 'postgresql':
        return 5
    elif engine == 'snowflake':
        return 6
    else:
        return wr.s3.read_parquet(path=source)

def get_source_name(source,engine):
    if engine == 's3':
        if type(source) == list:
            source_name = re.search('.*/(.+?)(\_(\d.*)|).parquet', source[0]).group(1)
        else:
            source_name = re.search('.*/(.+?)(\_(\d.*)|).parquet', source).group(1)
        return source_name
    elif engine == 'athena':
        return 2
    elif engine == 'redshift':
        return 3
    elif engine == 'hudi':
        return 4
    elif engine == 'postgresql':
        return 5
    elif engine == 'snowflake':
        return 6
    else:
        if type(source) == list:
            source_name = re.search('.*/(.+?)(\_(\d.*)|).parquet', source[0]).group(1)
        else:
            source_name = re.search('.*/(.+?)(\_(\d.*)|).parquet', source).group(1)
        return source_name

def prepare_final_ds(source,engine,source_engine):

    # if type(source) == list:
    #     source_name = get_source_name(source, engine)
    #     # source = concat_source_list(source,engine,source_engine)
    # else:
    #     source_name = get_source_name(source, engine)
    #     # source = prepare_source(source,engine,source_engine)
    source_name = get_source_name(source, engine)
    df = read_source(source,engine)

    return df,source_name
