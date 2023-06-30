FROM public.ecr.aws/lambda/python:3.9 as base
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
COPY ./report_push/*.py ./

FROM base as unit-tests
RUN pip install pytest==7.3.1 moto==4.1.6
ENV ENVIRONMENT=local \
    BUCKET=test-bucket \
    DYNAMODB_TABLE=test-table \
    AWS_ACCESS_KEY_ID=test \
    AWS_SECRET_ACCESS_KEY=test \
    AWS_DEFAULT_REGION=us-east-1 \
    SNS_BUGS_TOPIC_ARN=test-topic-arn \
    JIRA_URL=https://jira.localhost \
    DATAQA_JIRA_USERNAME=qauser \
    DATAQA_JIRA_PASSWORD=qapassword
COPY ./tests/test*.py ./
ENTRYPOINT ["pytest", "-qvs"]

FROM base as production
CMD ["push_data_report.handler"]
