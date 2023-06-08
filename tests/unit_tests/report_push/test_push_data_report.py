import pytest
from push_data_report import push_cloudwatch_metrics
from moto import mock_cloudwatch
import boto3


suite = 'test_suite'
environment = 'test_environment'


@pytest.fixture
@mock_cloudwatch
def conn():
    return boto3.client('cloudwatch', region_name='us-east-1')


@mock_cloudwatch
def test_push_cloudwatch_metrics_bug_created(conn):
    # Define test input
    failed = 0
    created_bug_count = 3

    # Call the method under test
    push_cloudwatch_metrics(suite, environment, failed, created_bug_count,
                            conn)
    metrics = conn.list_metrics()["Metrics"]
    assert metrics[0]['MetricName'] == 'bug_created_count'
    assert metrics[0]['Dimensions'][0]['Value'] == 'test_suite'
    assert metrics[0]['Dimensions'][1]['Value'] == 'test_environment'


@mock_cloudwatch
def test_push_cloudwatch_metrics(conn):
    # Define test input
    failed = 5
    created_bug_count = 0

    # Call the method under test
    push_cloudwatch_metrics(suite, environment, failed, created_bug_count,
                            conn)
    metrics = conn.list_metrics()["Metrics"]
    assert metrics[0]['MetricName'] == 'suite_failed_count'
    assert metrics[0]['Dimensions'][0]['Value'] == 'test_suite'
    assert metrics[0]['Dimensions'][1]['Value'] == 'test_environment'
