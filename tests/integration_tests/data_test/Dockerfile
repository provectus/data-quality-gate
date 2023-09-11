FROM python:3.9
RUN pip install pytest==7.3.1 jsonschema==4.0.1 boto3==1.26.66 requests==2.31.0  
COPY test_data ./test_data
COPY ./*.py ./
CMD ["pytest", "-qvs", "test_data_test.py"]"
