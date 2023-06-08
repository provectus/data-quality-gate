ARG IMAGE_NAME=data-test
ARG VERSION=latest
FROM ${IMAGE_NAME}:${VERSION}
RUN pip install pytest==7.3.1 moto==4.1.6
ENV ENVIRONMENT=local \
    REPORTS_WEB=test \
    AWS_ACCESS_KEY_ID=test \
    AWS_SECRET_ACCESS_KEY=test \
    AWS_DEFAULT_REGION=us-east-1 \
    REDSHIFT_DB=test \
    REDSHIFT_SECRET=test \
    S3_HOST=localhost \
    S3_PORT=9000 \
    BUCKET=test-bucket
COPY ./test*.py ./
ENTRYPOINT ["pytest", "-qvs"]
