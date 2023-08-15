FROM --platform=linux/amd64 python:3.9 as base
COPY requirements.txt ./
RUN pip3 install -r requirements.txt --no-cache-dir
COPY ./*.py ./
CMD ["python3", "-c", "import s3_access; s3_access.handler(1, 2)"]

