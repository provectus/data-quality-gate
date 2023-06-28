FROM public.ecr.aws/lambda/python:3.9 as base
COPY requirements.txt ./
RUN pip3 install -r requirements.txt --no-cache-dir
COPY ./data_test/*.py ./
COPY ./data_test/great_expectations ./great_expectations
RUN rm -f  /etc/timezone
RUN python3 -c "import tzlocal; tzlocal.get_localzone()"

FROM base as unit-tests
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
COPY ./tests/test*.py ./
ENTRYPOINT ["pytest","-qvs"]

FROM base as production
CMD ["data_test.handler"]
