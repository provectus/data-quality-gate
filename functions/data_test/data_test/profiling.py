import json
import math
import numpy as np
from ydata_profiling import ProfileReport
import os
import boto3
import awswrangler as wr
from ydata_profiling.model import expectation_algorithms
from ydata_profiling.model.handler import Handler
from Expectation_report_new import ExpectationsReportNew
from ydata_profiling.expectations_report import ExpectationsReport
from datetime import datetime
from great_expectations.data_context import EphemeralDataContext
from great_expectations.data_context.types.base import (DataContextConfig,
                                                        S3StoreBackendDefaults)
import yaml
from scipy.stats import t
from loguru import logger

DEFAULT_CONFIG_FILE_PATH = "great_expectations/great_expectations.yml"

if os.environ['ENVIRONMENT'] == 'local':
    endpoint_url = f"http://{os.environ['S3_HOST']}:{os.environ['S3_PORT']}"
    s3 = boto3.resource("s3", endpoint_url=endpoint_url)
else:
    endpoint_url = None
    s3 = boto3.resource("s3")

qa_bucket_name = os.environ['BUCKET']


def expectations_unique(name, summary, batch, *args):
    batch.expect_column_to_exist(column=name)
    if summary["p_unique"] >= 0.9:
        batch.expect_column_values_to_be_unique(column=name)
    return name, summary, batch


def expectations_null(name, summary, batch, *args):
    if summary["p_missing"] <= 0.4:
        batch.expect_column_values_to_not_be_null(column=name)
    return name, summary, batch


def expectations_mean(name, summary, batch, *args):
    min_mean, max_mean = calculate_mean(summary)
    batch.expect_column_mean_to_be_between(
        column=name, min_value=min_mean, max_value=max_mean)
    return name, summary, batch


def expectations_median(name, summary, batch, *args):
    min_median, max_median = calculate_median(summary)
    batch.expect_column_median_to_be_between(
        column=name, min_value=min_median, max_value=max_median)
    return name, summary, batch


def expectations_stdev(name, summary, batch, *args):
    min_std, max_std = calculate_stdev(summary)
    batch.expect_column_stdev_to_be_between(
        column=name, min_value=min_std, max_value=max_std)
    return name, summary, batch


def expectations_quantile(name, summary, batch, *args):
    value_ranges = calculate_q_ranges(summary)
    q_ranges = {
        "quantiles": [0.05, 0.25, 0.5, 0.75, 0.95],
        "value_ranges": value_ranges
    }
    batch.expect_column_quantile_values_to_be_between(
        column=name, quantile_ranges=q_ranges)
    return name, summary, batch


def expectations_z_score(name, summary, batch, *args):
    threshold = calculate_z_score(summary)
    if threshold and threshold == threshold:
        logger.debug("threshold is not None")
        batch.expect_column_value_z_scores_to_be_less_than(
            column=name, threshold=threshold, double_sided=False)
    return name, summary, batch


class MyExpectationHandler(Handler):
    def __init__(self, typeset, *args, **kwargs):
        mapping = {
            "Unsupported": [
                expectations_null,
            ],
            "Categorical": [
                expectation_algorithms.categorical_expectations,
                expectations_null,
            ],
            "Text": [
                expectation_algorithms.categorical_expectations,
                expectations_null],
            "Boolean": [
                expectations_null,
            ],
            "Numeric": [
                expectations_unique,
                expectations_null,
                expectation_algorithms.numeric_expectations,
                expectations_mean,
                expectations_median,
                expectations_stdev,
                expectations_quantile,
                expectations_z_score],
            "URL": [
                expectation_algorithms.url_expectations,
                expectations_null,
            ],
            "File": [
                expectation_algorithms.file_expectations,
                expectations_null,
            ],
            "Path": [
                expectation_algorithms.path_expectations,
                expectations_null,
            ],
            "DateTime": [
                expectation_algorithms.datetime_expectations,
                expectations_null,
            ],
            "Image": [
                expectation_algorithms.image_expectations,
                expectations_null,
            ],
        }
        super().__init__(mapping, typeset, *args, **kwargs)


def change_ge_config(datasource_root):
    configfile = read_gx_config_file()
    if os.environ['ENVIRONMENT'] == 'local':
        stores = configfile["stores"]
        new_stores = add_local_s3_to_stores(stores, endpoint_url)
        data_docs_sites = configfile["data_docs_sites"]
        new_data_docs_sites = add_local_s3_to_data_docs(data_docs_sites,
                                                        endpoint_url)
        config = DataContextConfig(
            config_version=configfile["config_version"],
            stores=new_stores,
            data_docs_sites=new_data_docs_sites,
            expectations_store_name=configfile["expectations_store_name"],
            validations_store_name=configfile["validations_store_name"],
            evaluation_parameter_store_name=configfile["evaluation_parameter_store_name"],
            plugins_directory="/great_expectations/plugins",
            validation_operators=configfile["validation_operators"],
            config_variables_file_path=configfile["config_variables_file_path"],
            anonymous_usage_statistics=configfile["anonymous_usage_statistics"],
            store_backend_defaults=S3StoreBackendDefaults(
                default_bucket_name=qa_bucket_name,
                expectations_store_prefix=f"{qa_bucket_name}/great_expectations/expectations/",
                validations_store_prefix=f"{qa_bucket_name}/great_expectations/uncommitted/validations/"))
    else:
        config = DataContextConfig(
            config_version=configfile["config_version"],
            expectations_store_name=configfile["expectations_store_name"],
            validations_store_name=configfile["validations_store_name"],
            evaluation_parameter_store_name=configfile["evaluation_parameter_store_name"],
            plugins_directory="/great_expectations/plugins",
            validation_operators=configfile["validation_operators"],
            config_variables_file_path=configfile["config_variables_file_path"],
            anonymous_usage_statistics=configfile["anonymous_usage_statistics"],
            store_backend_defaults=S3StoreBackendDefaults(
                default_bucket_name=qa_bucket_name,
                expectations_store_prefix=f"{qa_bucket_name}/great_expectations/expectations/",
                validations_store_prefix=f"{qa_bucket_name}/great_expectations/uncommitted/validations/"))
    return config


def add_local_s3_to_stores(stores, endpoint_url):
    boto_options_dic = {'endpoint_url': endpoint_url}
    for store in stores:
        if stores[store].get('store_backend'):
            stores[store]['store_backend']['boto3_options'] = boto_options_dic
    return stores


def add_local_s3_to_data_docs(data_docs_sites, endpoint_url):
    boto_options_dic = {'endpoint_url': endpoint_url}
    data_docs_sites['s3_site']['store_backend']['boto3_options'] = boto_options_dic
    return data_docs_sites


def remove_suffix(input_string, suffix):
    if suffix and input_string.endswith(suffix):
        return input_string[:-len(suffix)]
    return input_string


def read_gx_config_file(path=None) -> dict:
    if path is None:
        path = DEFAULT_CONFIG_FILE_PATH
    with open(path, "r") as config_file:
        configfile = yaml.safe_load(config_file)
    return configfile


def calculate_mean(summary):
    n = summary["n"]
    k = 0.99 * (summary["std"] / math.sqrt(n))
    min_mean = summary["mean"] - k
    max_mean = summary["mean"] + k
    return min_mean, max_mean


def calculate_median(summary):
    raw_values = summary["value_counts_index_sorted"]
    values = []
    for key, v in raw_values.items():
        key = [key] * v
        values.extend(key)
    q = 0.5
    j = int(len(values) * q - 2.58 * math.sqrt(len(values) * q * (1 - q)))
    k = int(len(values) * q + 2.58 * math.sqrt(len(values) * q * (1 - q))) - 1
    if j >= 1:
        j -= 1
    min_median = values[j]
    max_median = values[k]
    return min_median, max_median


def calculate_stdev(summary):
    n = summary["n"]
    std = summary["std"]
    confidence_level = 0.99
    degrees_of_freedom = n - 1
    alpha = 1 - confidence_level
    t_critical = t.ppf(1 - alpha / 2, degrees_of_freedom)
    margin_of_error = t_critical * (std / math.sqrt(n))
    min_std = std - margin_of_error
    max_std = std + margin_of_error
    return min_std, max_std


def calculate_z_score(summary):
    mean = summary["mean"]
    std = summary["std"]
    maximum = summary["max"]
    significance_level = 0.005
    if std and not np.isnan(std):
        threshold = (maximum - mean) / std
        return threshold + significance_level
    else:
        return None


def calculate_q_ranges(summary):
    return [[summary["5%"], summary["25%"]], [summary["25%"], summary["50%"]],
            [summary["50%"], summary["75%"]], [summary["75%"], summary["95%"]],
            [summary["95%"], summary["max"]]]


def profile_data(df, suite_name, cloudfront, datasource_root, source_covered,
                 mapping_config, run_name):
    logger.info("starting profiling")
    qa_bucket = s3.Bucket(qa_bucket_name)
    config = change_ge_config(datasource_root)
    context_ge = EphemeralDataContext(project_config=config)
    datasource = context_ge.sources.add_pandas(name="cloud")
    data_asset = datasource.add_dataframe_asset(name=suite_name, dataframe=df)
    try:
        profile = ProfileReport(df, title=f"{suite_name} Profiling Report",
                                minimal=True, pool_size=1)
        logger.info("profiling in minimal mode")
    except TypeError:
        profile = ProfileReport(df, title=f"{suite_name} Profiling Report",
                                pool_size=1)
        logger.warning("profiling in default mode")
    try:
        report = profile.to_html()
        logger.debug("profiling converted to html successfully")
    except ValueError:
        profile.config.vars.text.words = False
        report = profile.to_html()
        logger.warning("profiling had problems with text.words during process")

    if not source_covered:
        logger.debug("suite is not covered")
        try:
            pipeline_config = json.loads(wr.s3.read_json(
                path=f"s3://{qa_bucket_name}/test_configs/pipeline.json").to_json())
            reuse_suite = pipeline_config[run_name]['reuse_suite']
            use_old_suite_only = pipeline_config[run_name]['use_old_suite_only']
            old_suite_name = pipeline_config[run_name]['old_suite_name']
            logger.debug("all params were found at configs for pipeline")
        except KeyError:
            reuse_suite = False
            use_old_suite_only = False
            old_suite_name = None
            logger.warning("some params were not found at configs for pipeline")
        ExpectationsReport.to_expectation_suite = ExpectationsReportNew.to_expectation_suite
        suite = profile.to_expectation_suite(
            data_context=context_ge,
            suite_name=remove_suffix(suite_name, f"_{run_name}"),
            run_name=run_name,
            reuse_suite=reuse_suite,
            mapping_config=mapping_config,
            use_old_suite=use_old_suite_only,
            old_suite_name=old_suite_name,
            handler=MyExpectationHandler(profile.typeset)
        )
    folder = 'profiling/'
    now = datetime.now()
    date_time = now.strftime("%y%m%dT%H%M%S")
    folder = f"{folder}{suite_name}/{str(date_time)}/"

    qa_bucket.put_object(Key=folder)
    qa_bucket.put_object(Key=f"{folder}{suite_name}_profiling.html",
                         Body=report, ContentType='text/html')
    profile_link = f"{cloudfront}/{folder}{suite_name}_profiling.html"
    logger.info("profiling is finished")
    return profile_link, date_time, context_ge, data_asset
