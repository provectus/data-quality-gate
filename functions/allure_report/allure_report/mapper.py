import json
import os
from datetime import datetime
from great_expectations.expectations.expectation import (
    ExpectationConfiguration,
)
from great_expectations.expectations.registry import (
    get_expectation_impl)
import shutil
import awswrangler as wr
import boto3
import re
from loguru import logger
qa_bucket = os.environ['BUCKET']
s3 = boto3.resource('s3')
bucket = s3.Bucket(qa_bucket)


def get_test_human_name(file):
    exp = get_expectation_impl(get_test_name(file))
    template_json = \
        exp._prescriptive_renderer(configuration=ExpectationConfiguration(
            get_test_name(file), kwargs=get_params1(file)))[0]
    if type(template_json) is not dict:
        template_json = template_json.to_json_dict()
    template_str = template_json['string_template']['template']
    params = get_params1(file)
    result_string = template_str
    new_params = {}
    for key, value in params.items():
        if type(value) == list:
            if key == 'value_set':
                logger.debug("key in param is value_set")
                for i in value:
                    new_params[f"v__{str(value.index(i))}"] = i
            elif key == 'column_set':
                logger.debug("key in param is column_set")
                for i in value:
                    new_params[f"column_list_{str(value.index(i))}"] = i
            else:
                for i in value:
                    logger.debug("key in param is other")
                    new_params[f"{str(key)}_{str(value.index(i))}"] = i

    if new_params:
        if 'value_set' in params.keys():
            del params['value_set']
            params.update(new_params)
        elif 'column_list' in params.keys():
            del params['column_list']
            params.update(new_params)
        else:
            params = new_params
    for key, value in params.items():
        result_string = re.sub(
            rf'\${key}\b', re.escape(str(value)), result_string)
    return result_string


def get_json(json_name, validate_id):
    file_name = f"great_expectations/uncommitted/validations/{validate_id}.json"
    content_object = s3.Object(qa_bucket, f"{qa_bucket}/{file_name}")
    file_content = content_object.get()['Body'].read().decode('utf-8')
    json_content = json.loads(file_content)
    return json_content


def get_suit_status():
    return "passed"


def get_test_name(file):
    return file['expectation_config']['expectation_type']


def get_suit_name(file, i):
    if "column" in i["expectation_config"]["kwargs"]:
        column = i["expectation_config"]["kwargs"]["column"]
        data_asset_name = file["meta"]["active_batch_definition"]["data_asset_name"]
        return f"{data_asset_name}.{column}"
    return file["meta"]["active_batch_definition"]["data_asset_name"]


def get_jira_ticket(file):
    if 'Bug Ticket' in file['expectation_config']['meta']:
        return {
            "name": "Bug ticket",
            "url": file['expectation_config']['meta']['Bug Ticket'],
            "type": "issue"
        }
    return {}


def get_severity(file):
    if 'Severity' in file['expectation_config']['meta']:
        return file['expectation_config']['meta']['Severity']
    return ""


def get_start_suit_time(file):
    return parse_datetime(file['meta']['batch_markers']['ge_load_time'])


def get_stop_suit_time():
    return datetime.now().timestamp()


def parse_datetime(date_str):
    if '+00:00' in date_str:
        return datetime.timestamp(datetime.strptime(date_str, '%Y-%m-%dT%H:%M:%S.%f+00:00')) * 1000
    else:
        return datetime.timestamp(datetime.strptime(date_str, '%Y%m%dT%H%M%S.%fZ')) * 1000


def get_start_test_time(file):
    return parse_datetime(file['meta']['run_id']['run_time'])


def get_stop_test_time(file):
    return parse_datetime(file['meta']['validation_time'])


def get_params(file):
    params = file['expectation_config']['kwargs']
    del params['batch_id']
    results = []
    for param in params:
        if isinstance(params[param], (list, dict)):
            value = str(params[param])
        else:
            value = params[param]
        results.append({"name": param, "value": value})
    return results


def get_params1(file):
    return file['expectation_config']['kwargs']


def get_test_status(file):
    return "passed" if file['success'] is True else "failed"


def get_test_description(file):
    result = ""
    for f in file["result"]:
        if str(f) != "observed_value":
            result = result + "\n" + \
                     f"{str(f)}: {str(file['result'][f])}" + "\n"
    return result


def get_observed_value(file):
    try:
        if "observed_value" in file["result"]:
            return f"Observed value: {str(file['result']['observed_value'])}"
        return f"Unexpected count: {str(file['result']['unexpected_count'])}"
    except KeyError:
        return 'Column not exist'


def get_exception_message(file):
    return file['exception_info']['exception_message']


def get_exception_traceback(file):
    return file['exception_info']['exception_traceback']


def get_folder_key(folder, folder_key):
    folder = f"{folder}{str(folder_key)}/"
    bucket.put_object(Key=folder)
    return folder_key


def create_categories_json(json_name, key):
    data = [
        {
            "name": "Ignored tests",
            "matchedStatuses": [
                "skipped"
            ]
        },
        {
            "name": "Passed tests",
            "matchedStatuses": [
                "passed"
            ]
        },
        {
            "name": "Broken tests",
            "matchedStatuses": [
                "broken"
            ]
        },
        {
            "name": "Failed tests",
            "matchedStatuses": [
                "failed"
            ]
        }
    ]

    result = json.dumps(data)
    s3.Object(qa_bucket,
              f"allure/{json_name}{key}/result/categories.json").put(
        Body=bytes(result.encode("UTF-8")))


def get_uuid(i, json_name, key):
    fl = ""
    objs = list(bucket.objects.filter(
        Prefix=f"allure/{json_name}{key}/allure-report/history"))
    if (len(objs) > 0):
        df = wr.s3.read_json(
            path=[f"s3://{qa_bucket}/allure/{json_name}{key}/allure-report/history/history.json"])
        fl = json.loads(df.to_json())
        keys = list(fl.keys())
        keys.sort()
        return keys[i]
    else:
        return datetime.now().strftime("%S%f")


def create_suit_json(json_name, key, validate_id):
    bucket.put_object(Key=f"allure/{json_name}{key}/result/")

    file = get_json(json_name, validate_id)
    start_time = get_start_suit_time(file)
    stop_time = get_stop_test_time(file)
    for i in file['results']:
        uuid = str(get_uuid(list(file['results']).index(i), json_name, key))
        message = (get_observed_value(i)
                   if get_test_status(i) == 'failed'
                   else "")
        data = {
            "uuid": uuid,
            "historyId": uuid,
            "status": get_test_status(i),
            "parameters": get_params(i),
            "labels": [{
                "name": "test",
                "value": get_test_name(i)
            }, {
                "name": "suite",
                "value": get_suit_name(file, i)
            },
                {
                    "name": "severity",
                    "value": get_severity(i)
                }
            ],
            "links": [get_jira_ticket(i)],
            "name": get_test_name(i),
            "description": get_test_description(i),
            "statusDetails": {"known": False, "muted": False, "flaky": False,
                              "message": message,
                              "trace": get_exception_traceback(i)},
            "start": start_time,
            "stop": stop_time,
            "steps": [
                {
                    "status": get_test_status(i),
                    "name": get_test_human_name(i),
                    "start": get_start_test_time(file),
                    "stop": get_stop_test_time(file)
                }]
        }

        result = json.dumps(data)

        s3.Object(qa_bucket, f"allure/{json_name}{key}/result/{uuid}-result.json").put(
            Body=bytes(result.encode("UTF-8")))


def transfer_folder(root_src_dir, root_dst_dir):
    for src_dir, dirs, files in os.walk(root_src_dir):
        dst_dir = src_dir.replace(root_src_dir, root_dst_dir, 1)
        if not os.path.exists(dst_dir):
            os.makedirs(dst_dir)
        for file_ in files:
            src_file = os.path.join(src_dir, file_)
            dst_file = os.path.join(dst_dir, file_)
            if os.path.exists(dst_file):
                # in case of the src and dst are the same file
                if os.path.samefile(src_file, dst_file):
                    continue
                os.remove(dst_file)
            shutil.copy(src_file, dst_dir)


def create_json_report(json_name, cloudfront, folder_key, validate_id):
    key = "/" + get_folder_key(f"allure/{json_name}/", folder_key)
    create_suit_json(json_name, key, validate_id)
    create_categories_json(json_name, key)
    return f"{cloudfront}/allure/{json_name}{key}/allure-report/index.html", json_name + key
