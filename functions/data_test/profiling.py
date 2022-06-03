import numpy as np
import pandas as pd
from pandas_profiling import ProfileReport
import os
import s3fs
import boto3
import awswrangler as wr
import re
from pandas_profiling.model import expectation_algorithms
from pandas_profiling.model.handler import Handler
import great_expectations as ge
from Expectation_report_new import ExpectationsReportNew
from pandas_profiling.expectations_report import ExpectationsReport
from datetime import datetime
from great_expectations import DataContext
from great_expectations.data_context import BaseDataContext
from great_expectations.data_context.store import TupleFilesystemStoreBackend
from great_expectations.data_context.types.base import DataContextConfig, S3StoreBackendDefaults
import yaml
from great_expectations.data_context import BaseDataContext

s3 = boto3.resource("s3")
qa_bucket_name = os.environ['QA_BUCKET']
def generic_expectations_without_null(name, summary, batch, *args):
    batch.expect_column_to_exist(column=name)
    if summary["p_unique"] >= 0.9:
        batch.expect_column_values_to_be_unique(column=name)
    return name, summary, batch


def expectations_null(name, summary, batch, *args):
    if summary["p_missing"] <= 0.4:
        batch.expect_column_values_to_not_be_null(column=name)
    return name, summary, batch


class MyExpectationHandler(Handler):
    def __init__(self, typeset, *args, **kwargs):
        mapping = {
            "Unsupported": [generic_expectations_without_null, expectations_null,
                            ],
            "Categorical": [expectation_algorithms.categorical_expectations,
                            expectations_null,

                            ],
            "Boolean": [expectations_null,
                        ],
            "Numeric": [generic_expectations_without_null, expectations_null,
                        ],
            "URL": [expectation_algorithms.url_expectations, expectations_null,
                    ],
            "File": [expectation_algorithms.file_expectations, expectations_null,
                     ],
            "Path": [expectation_algorithms.path_expectations, expectations_null,
                     ],
            "DateTime": [expectation_algorithms.datetime_expectations, expectations_null,
                         ],
            "Image": [expectation_algorithms.image_expectations, expectations_null,
                      ],
        }

        super().__init__(mapping, typeset, *args, **kwargs)


def change_ge_config(datasource_root, datasource_folder,engine):
    context_ge = DataContext()

    configfile_raw = context_ge.get_config().to_yaml_str()
    configfile = yaml.safe_load(configfile_raw)

    match engine:
        case 's3':
            datasources = {
                "pandas_s3": {
                    "class_name": "PandasDatasource",
                    "batch_kwargs_generators": {
                        "pandas_s3_generator": {
                            "class_name": "S3GlobReaderBatchKwargsGenerator",
                            "bucket": datasource_root,
                            "assets": {
                                "your_first_data_asset_name": {
                                    "prefix": "/",
                                    "regex_filter": ".*"
                                }
                            }
                        }
                    },
                    "module_name": "great_expectations.datasource",
                    "data_asset_type": {
                        "class_name": "PandasDataset",
                        "module_name": "great_expectations.dataset"
                    }
                }
            }

            config = DataContextConfig(config_version=configfile['config_version'], datasources=datasources,
                                       expectations_store_name=configfile['expectations_store_name'],
                                       validations_store_name=configfile['validations_store_name'],
                                       evaluation_parameter_store_name=configfile['evaluation_parameter_store_name'],
                                       plugins_directory='/great_expectations/plugins',
                                       validation_operators=configfile['validation_operators'],
                                       config_variables_file_path=configfile['config_variables_file_path'],
                                       anonymous_usage_statistics=configfile['anonymous_usage_statistics'],
                                       store_backend_defaults=S3StoreBackendDefaults(
                                           default_bucket_name=qa_bucket_name,
                                           expectations_store_prefix=qa_bucket_name + '/great_expectations/expectations/',
                                           validations_store_prefix=qa_bucket_name + '/great_expectations/uncommitted/validations/'))
            return config
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
            return s3.Bucket(datasource_root)





def select_engine_source(datasource_root,engine):
    match engine:
        case 's3':
            return s3.Bucket(datasource_root)
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
            return s3.Bucket(datasource_root)

def profile_data(file, file_name, cloudfront, datasource_root, datasource_folder, source_covered,engine):
    qa_bucket = s3.Bucket(qa_bucket_name)
    config = change_ge_config(datasource_root)
    context_ge = BaseDataContext(project_config=config)
    df = file
    try:
        profile = ProfileReport(df, title=file + " Profiling Report", minimal=True)
        report = profile.to_html()
    except TypeError:
        profile = ProfileReport(df, title=file + " Profiling Report")
        report = profile.to_html()


    if not source_covered:
        ExpectationsReport.to_expectation_suite = ExpectationsReportNew.to_expectation_suite
        suite = profile.to_expectation_suite(
            data_context=context_ge,
            suite_name=file_name,
            save_suite=True,
            run_validation=False,
            build_data_docs=False,
            handler=MyExpectationHandler(profile.typeset)
        )

    folder = 'profiling/'
    now = datetime.now()
    date_time = now.strftime("%y%m%dT%H%M%S")
    folder = folder + file_name + '/' + str(date_time) + '/'
    qa_bucket.put_object(Key=folder)
    qa_bucket.put_object(Key=folder + file_name + '_profiling.html', Body=report, ContentType='text/html')
    profile_link = cloudfront + "/" + folder + file_name + "_profiling.html"
    return profile_link, date_time, config
