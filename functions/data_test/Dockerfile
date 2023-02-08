FROM public.ecr.aws/lambda/python:3.7
COPY ./*.py ./
COPY great_expectations ./great_expectations
COPY requirements.txt ./
RUN pip3 install -r requirements.txt --no-cache-dir
RUN rm -f  /etc/timezone
RUN python3 -c "import tzlocal; tzlocal.get_localzone()"
CMD ["data_test.handler"]