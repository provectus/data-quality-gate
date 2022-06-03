FROM python:3.6-stretch
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip
RUN pip3 install --upgrade cython
RUN pip3 install setuptools_scm
ADD ./requirements.txt ./
RUN pip3 install  -r requirements.txt
COPY  push_data_report.py ./
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["push_data_report.handler"]