FROM data-test:latest
RUN pip3 install pytest==7.2.0
ENV ENVIRONMENT local
ENV QA_CLOUDFRONT test
ENV AWS_ACCESS_KEY_ID test
ENV AWS_SECRET_ACCESS_KEY test
ENV AWS_DEFAULT_REGION us-east-1
COPY test_data ./test_data
COPY ./*.py ./
ENTRYPOINT ["pytest", "-qvs", "test_data_test.py"]