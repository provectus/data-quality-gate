#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from great_expectations import DataContext
import great_expectations as ge
import os
from pathlib import Path
import s3fs
import boto3
BASE_DIR = Path(__file__).resolve().parent
from great_expectations.data_context import BaseDataContext
def validate_data(file,suite_name,config):
    s3 = boto3.resource("s3")
    context_ge = BaseDataContext(project_config=config)

    expectation_suite_name = suite_name

    suite = context_ge.get_expectation_suite(expectation_suite_name)



    batch_kwargs = {'dataset': file,
                        'datasource': "pandas_s3",
                        'data_asset_name': expectation_suite_name}
    batch = context_ge.get_batch(
            batch_kwargs=batch_kwargs,
            expectation_suite_name=expectation_suite_name
        )


    results = context_ge.run_validation_operator("action_list_operator", assets_to_validate=[batch])
    validation_result_identifier = results.list_validation_result_identifiers()[0]
    if(not results['success']):
        context_ge.build_data_docs(
            site_names='s3_site',
            resource_identifiers=[validation_result_identifier]
        )
    return str(validation_result_identifier).replace('ValidationResultIdentifier::','')

