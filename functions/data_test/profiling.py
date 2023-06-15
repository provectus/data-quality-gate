import json

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
import math
from scipy.stats import t

s3 = boto3.resource("s3", endpoint_url=f"http://{os.environ['S3_HOST']}:4566") if os.environ[
                                                                                      'ENVIRONMENT'] == 'local' else boto3.resource(
    "s3")

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


def expectations_mean(name, summary, batch, *args):
    n = summary["n"]
    k = 0.99 * (summary["std"] / math.sqrt(n))
    min_mean = summary["mean"] - k
    max_mean = summary["mean"] + k
    batch.expect_column_mean_to_be_between(
        column=name, min_value=min_mean, max_value=max_mean)
    return name, summary, batch


def expectations_median(name, summary, batch, *args):
    raw_values = summary["value_counts_index_sorted"]
    values = []
    for key, v in raw_values.items():
        key = [key] * v
        values.extend(key)
    q = 0.5
    j = int(len(values) * q - 2.58 * math.sqrt(len(values) * q * (1 - q)))
    k = int(len(values) * q + 2.58 * math.sqrt(len(values) * q * (1 - q)))
    if j < len(values) and k < len(values):
        min_median = values[j]
        max_median = values[k]
        batch.expect_column_median_to_be_between(
            column=name, min_value=min_median, max_value=max_median)
    return name, summary, batch


def expectations_stdev(name, summary, batch, *args):
    n = summary["n"]
    std = summary["std"]
    confidence_level = 0.99
    degrees_of_freedom = n - 1
    alpha = 1 - confidence_level
    t_critical = t.ppf(1 - alpha / 2, degrees_of_freedom)
    margin_of_error = t_critical * (std / math.sqrt(n))
    min_std = std - margin_of_error
    max_std = std + margin_of_error
    batch.expect_column_stdev_to_be_between(
        column=name, min_value=min_std, max_value=max_std)
    return name, summary, batch


def expectations_quantile(name, summary, batch, *args):
    q_ranges = {
        "quantiles": [0.05, 0.25, 0.5, 0.75, 0.95],
        "value_ranges": [[summary["5%"], summary["25%"]], [summary["25%"], summary["50%"]],
                         [summary["50%"], summary["75%"]], [summary["75%"], summary["95%"]],
                         [summary["95%"], summary["max"]]]
    }
    batch.expect_column_quantile_values_to_be_between(
        column=name, quantile_ranges=q_ranges)
    return name, summary, batch


def expectations_z_score(name, summary, batch, *args):
    mean = summary["mean"]
    std = summary["std"]
    maximum = summary["max"]
    threshold = (maximum - mean) / std
    if std != 0:
        batch.expect_column_value_z_scores_to_be_less_than(
            column=name, threshold=threshold, double_sided=True)
    return name, summary, batch


class MyExpectationHandler(Handler):
    def __init__(self, typeset, *args, **kwargs):
        mapping = {
            "Unsupported": [generic_expectations_without_null, expectations_null,
                            ],
            "Categorical": [expectation_algorithms.categorical_expectations,
                            expectations_null
                            ],
            "Boolean": [expectations_null,
                        ],
            "Numeric": [generic_expectations_without_null, expectations_null,
                        expectation_algorithms.numeric_expectations, expectations_mean,
                        expectations_median, expectations_stdev, expectations_quantile
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


def change_ge_config(datasource_root, project_name):
    context_ge = DataContext()

    configfile_raw = context_ge.get_config().to_yaml_str()
    configfile = yaml.safe_load(configfile_raw)

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

    if os.environ['ENVIRONMENT'] == 'local':
        stores = configfile["stores"]
        new_stores = add_local_s3_to_stores(stores) if os.environ['ENVIRONMENT'] == 'local' else stores
        data_docs_sites = configfile["data_docs_sites"]
        new_data_docs_sites = add_local_s3_to_data_docs(data_docs_sites) if os.environ[
                                                                                'ENVIRONMENT'] == 'local' else data_docs_sites
        config = DataContextConfig(config_version=configfile["config_version"], datasources=datasources,
                                   stores=new_stores, data_docs_sites=new_data_docs_sites,
                                   expectations_store_name=configfile["expectations_store_name"],
                                   validations_store_name=configfile["validations_store_name"],
                                   evaluation_parameter_store_name=configfile["evaluation_parameter_store_name"],
                                   plugins_directory="/great_expectations/plugins",
                                   validation_operators=configfile["validation_operators"],
                                   config_variables_file_path=configfile["config_variables_file_path"],
                                   anonymous_usage_statistics=configfile["anonymous_usage_statistics"],
                                   store_backend_defaults=S3StoreBackendDefaults(
                                       default_bucket_name=qa_bucket_name,
                                       expectations_store_prefix=f"{qa_bucket_name}/great_expectations/expectations/{project_name}/",
                                       validations_store_prefix=f"{qa_bucket_name}/great_expectations/uncommitted/validations/"))
    else:
        config = DataContextConfig(config_version=configfile["config_version"], datasources=datasources,
                                   expectations_store_name=configfile["expectations_store_name"],
                                   validations_store_name=configfile["validations_store_name"],
                                   evaluation_parameter_store_name=configfile["evaluation_parameter_store_name"],
                                   plugins_directory="/great_expectations/plugins",
                                   validation_operators=configfile["validation_operators"],
                                   config_variables_file_path=configfile["config_variables_file_path"],
                                   anonymous_usage_statistics=configfile["anonymous_usage_statistics"],
                                   store_backend_defaults=S3StoreBackendDefaults(
                                       default_bucket_name=qa_bucket_name,
                                       expectations_store_prefix=f"{qa_bucket_name}/great_expectations/expectations/{project_name}/",
                                       validations_store_prefix=f"{qa_bucket_name}/great_expectations/uncommitted/validations/"))
    return config


def add_local_s3_to_stores(stores):
    boto_options_dic = {'endpoint_url': f"http://{os.environ['S3_HOST']}:4566"}
    for store in stores:
        if stores[store].get('store_backend'):
            stores[store]['store_backend']['boto3_options'] = boto_options_dic
    return stores


def add_local_s3_to_data_docs(data_docs_sites):
    boto_options_dic = {'endpoint_url': f"http://{os.environ['S3_HOST']}:4566"}
    data_docs_sites['s3_site']['store_backend']['boto3_options'] = boto_options_dic
    return data_docs_sites


def profile_data(df, suite_name, cloudfront, datasource_root, source_covered, mapping_config, run_name, project_name):
    try:
        mapping_schema = mapping_config[suite_name.split('_')[0]]
    except KeyError:
        mapping_schema = None

    qa_bucket = s3.Bucket(qa_bucket_name)
    config = change_ge_config(datasource_root, project_name)
    context_ge = BaseDataContext(project_config=config)
    try:
        profile = ProfileReport(df, title=f"{suite_name} Profiling Report", minimal=True)
        report = profile.to_html()
    except TypeError:
        profile = ProfileReport(df, title=f"{suite_name} Profiling Report")
        report = profile.to_html()
    if not source_covered:
        try:
            pipeline_config = json.loads(
                wr.s3.read_json(path=f"s3://{qa_bucket_name}/test_configs/{project_name}/pipeline.json").to_json())
            reuse_suite = pipeline_config[run_name]['reuse_suite']
            use_old_suite_only = pipeline_config[run_name]['use_old_suite_only']
            old_suite_name = pipeline_config[run_name]['old_suite_name']
        except KeyError:
            reuse_suite = False
            use_old_suite_only = False
            old_suite_name = None
        ExpectationsReport.to_expectation_suite = ExpectationsReportNew.to_expectation_suite
        suite = profile.to_expectation_suite(
            data_context=context_ge,
            suite_name=suite_name,
            save_suite=True,
            run_validation=False,
            build_data_docs=False,
            reuse_suite=reuse_suite,
            mapping_schema=mapping_schema,
            use_old_suite=use_old_suite_only,
            old_suite_name=old_suite_name,
            handler=MyExpectationHandler(profile.typeset)
        )
    folder = 'profiling/'
    now = datetime.now()
    date_time = now.strftime("%y%m%dT%H%M%S")
    folder = f"{folder}{suite_name}/{str(date_time)}/"

    qa_bucket.put_object(Key=folder)
    qa_bucket.put_object(Key=f"{folder}{suite_name}_profiling.html", Body=report, ContentType='text/html')
    profile_link = f"{cloudfront}/{folder}{suite_name}_profiling.html"
    return profile_link, date_time, config
