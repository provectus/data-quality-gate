FROM python:3.7
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip
RUN pip3 install --upgrade cython
RUN pip3 install setuptools_scm
RUN apt-get install debconf
RUN rm -f  /etc/timezone
#RUN rm -f /etc/localtime /etc/timezone
#RUN dpkg-reconfigure -f noninteractive tzdata
#RUN TZ=UTC ls -l --full-time
RUN pip3 install tzlocal && python3 -c "import tzlocal; tzlocal.get_localzone()"
ADD ./requirements.txt ./
COPY data_test.py ./
COPY profiling.py ./
COPY suite_run.py ./
COPY datasource.py ./
COPY Expectation_report_new.py ./
COPY great_expectations /great_expectations
RUN pip3 install  -r requirements.txt
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["data_test.handler"]
