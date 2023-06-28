FROM public.ecr.aws/lambda/python:3.9 as base
RUN yum install -y unzip java-1.8.0-openjdk
ENV JAVA_HOME=/usr/
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
RUN mkdir allure && curl https://github.com/allure-framework/allure2/releases/download/2.14.0/allure-2.14.0.zip -O -L -C - \
&& unzip allure-2.14.0.zip -d allure && rm allure-2.14.0.zip \
&& curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -O -L -C -\
&& unzip awscli-exe-linux-x86_64.zip && rm awscli-exe-linux-x86_64.zip \
&& ./aws/install
COPY ./allure_report/*.py ./
COPY ./allure_report/*.sh ./

FROM base as unit-tests
RUN pip install pytest==7.3.1
ENV BUCKET=test-bucket
COPY ./tests/test*.py ./
ENTRYPOINT ["pytest", "-qvs"]

FROM base as production
CMD ["make_allure_report.handler"]
