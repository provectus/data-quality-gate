ARG IMAGE_NAME=data-test
ARG VERSION=latest
FROM ${IMAGE_NAME}:${VERSION}
RUN pip install pytest==7.3.1
ENV ENVIRONMENT local
ENV REPORTS_WEB test
ENV AWS_ACCESS_KEY_ID test
ENV AWS_SECRET_ACCESS_KEY test
ENV AWS_DEFAULT_REGION us-east-1
COPY test_data ./test_data
COPY ./*.py ./
ENTRYPOINT ["pytest", "-qvs", "test_data_test.py"]