FROM python:3.7-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends
#see .dockerignore
COPY ./ ./
RUN pip3 install  -r requirements.txt --no-cache-dir
ENTRYPOINT ["/usr/local/bin/python", "-m", "awslambdaric"]
CMD ["push_data_report.handler"]
