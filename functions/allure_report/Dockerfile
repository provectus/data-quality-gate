FROM public.ecr.aws/lambda/python:3.8
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
RUN yum install -y unzip java-1.8.0-openjdk
RUN mkdir allure && curl https://github.com/allure-framework/allure2/releases/download/2.14.0/allure-2.14.0.zip -O -L -C - \
&& unzip allure-2.14.0.zip -d allure && rm allure-2.14.0.zip \
&& curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O -L -C -\
&& unzip awscli-exe-linux-x86_64.zip && rm awscli-exe-linux-x86_64.zip
RUN ./aws/install
COPY ./*.py ./
COPY ./*.sh ./
CMD ["make_allure_report.handler"]