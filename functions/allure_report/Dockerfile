FROM public.ecr.aws/lambda/python:3.7
RUN yum install -y wget
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
RUN mkdir allure && wget https://github.com/allure-framework/allure2/releases/download/2.14.0/allure-2.14.0.zip \
&& unzip allure-2.14.0.zip -d allure\
&& wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
&& unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install
COPY ./*.py ./
COPY ./*.sh ./
CMD ["make_allure_report.handler"]