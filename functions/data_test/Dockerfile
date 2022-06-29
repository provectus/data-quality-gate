FROM python:3.7-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends \
debconf
COPY ./*.py ./
COPY ./great_expectations ./
COPY ./requirements.txt ./
RUN pip3 install -r requirements.txt --no-cache-dir
RUN rm -f  /etc/timezone
RUN python3 -c "import tzlocal; tzlocal.get_localzone()"
RUN find . -type f -exec chmod 755 {} \;
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["data_test.handler"]
