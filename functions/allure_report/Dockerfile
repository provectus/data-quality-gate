ARG FUNCTION_DIR="/function"
FROM python:3.6-slim-bullseye AS build
RUN apt-get update && apt-get install -y --no-install-recommends \
python3-dev \
python3-pip \
software-properties-common \
unzip \
gcc \
wget
ARG FUNCTION_DIR
# Create function directory
RUN mkdir -p ${FUNCTION_DIR}
RUN pip3 install --target ${FUNCTION_DIR} --upgrade cython
RUN pip3 install --target ${FUNCTION_DIR} setuptools_scm
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt --target ${FUNCTION_DIR}
RUN mkdir allure && wget https://github.com/allure-framework/allure2/releases/download/2.14.0/allure-2.14.0.zip \ 
&& unzip allure-2.14.0.zip -d allure\
&& wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
&& unzip awscli-exe-linux-x86_64.zip
COPY mapper.py ${FUNCTION_DIR}
COPY make_allure_report.py ${FUNCTION_DIR}
COPY generate_report.sh ${FUNCTION_DIR}
FROM python:3.6-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends \
default-jre \
default-jdk 
ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}
COPY --from=build ${FUNCTION_DIR} ${FUNCTION_DIR}
COPY --from=build allure ${FUNCTION_DIR}/allure
COPY --from=build aws ${FUNCTION_DIR}/aws
RUN ./aws/install
RUN find . -type f -exec chmod 755 {} \;
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["make_allure_report.handler"]