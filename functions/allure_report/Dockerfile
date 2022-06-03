FROM python:3.6-stretch
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip
RUN pip3 install --upgrade cython
RUN pip3 install setuptools_scm
RUN apt-get install -y software-properties-common
RUN apt install default-jre -y
RUN apt install default-jdk -y
ADD ./requirements.txt ./
RUN pip3 install  -r requirements.txt
#RUN apt-add-repository -r ppa:qameta/allure
#RUN apt-get update -y
#RUN apt-get install allure
RUN mkdir allure
RUN cd allure
RUN wget https://github.com/allure-framework/allure2/releases/download/2.14.0/allure-2.14.0.zip
RUN apt install unzip -y
RUN unzip allure-2.14.0.zip
RUN cd ..
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
RUN unzip awscliv2.zip
RUN ./aws/install
COPY  mapper.py ./
COPY  make_allure_report.py ./
COPY generate_report.sh ./
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["make_allure_report.handler"]