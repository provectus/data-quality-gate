ARG IMAGE_NAME=report_push
ARG VERSION=latest
FROM ${IMAGE_NAME}:${VERSION}
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
COPY ./test*.py ./
ENTRYPOINT ["pytest", "-qvs"]
