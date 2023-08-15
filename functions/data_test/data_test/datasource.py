import os
import re
import pathlib
from data_source_factory import DataSourceFactory
from loguru import logger
qa_bucket_name = os.environ['BUCKET']


def concat_source_list(source, source_engine):
    final_source_files = []
    for sc in source:
        final_source_files.append(f"s3://{source_engine}/{sc}")
    return final_source_files


def get_file_extension(source):
    extension = pathlib.Path(source).suffix[1:]
    logger.debug(f"file extension is {extension}")
    return extension


def read_source(source, engine, extension, run_name, table_name=None,
                coverage_config=None):
    data_source = DataSourceFactory.create_data_source(engine, qa_bucket_name,
                                                       extension, run_name,
                                                       table_name,
                                                       coverage_config)
    return data_source.read(source)


def get_source_name(source, extension):
    result = re.search(r'.*/(.+?)(\_(\d.*)|).' + extension, source)
    return result.group(1) if result else None


def prepare_final_ds(source, engine, source_engine, run_name, source_name=None,
                     coverage_config=None):
    logger.info(f"Engine is {engine}")
    path = source
    if engine == 's3':
        source = concat_source_list(source, source_engine)
        source_extension = get_file_extension(source[0])
        df, path = read_source(source, engine, source_extension, run_name)
        logger.debug("going through s3 branch")
    elif engine == 'hudi':
        source = concat_source_list(source, source_engine)
        source_extension = get_file_extension(source[0])
        df, path = read_source(
            source, engine, source_extension, run_name, source_name)
        logger.debug("going through hudi branch")
    else:
        source = concat_source_list(source, source_engine)
        df, path = read_source(source, engine, None,
                               run_name, source_name, coverage_config)
        logger.debug("going through default branch")
    return df, path
