FROM public.ecr.aws/lambda/python:3.8
COPY ./*.py ./
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
CMD ["push_data_report.handler"]
