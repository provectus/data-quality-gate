ARG IMAGE_NAME=allure_report
ARG VERSION=latest
FROM ${IMAGE_NAME}:${VERSION}
RUN pip install pytest>=7.3.1
ENV BUCKET=test-bucket
COPY ./test*.py ./
ENTRYPOINT ["pytest", "-qvs"]
