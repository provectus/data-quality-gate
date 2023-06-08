FROM public.ecr.aws/lambda/python:3.9
ADD ./requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
COPY ./*.py ./
CMD ["push_data_report.handler"]
