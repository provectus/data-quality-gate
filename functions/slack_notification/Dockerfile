FROM public.ecr.aws/lambda/python:3.8.2023.01.11.07
COPY slack_notification.py ${LAMBDA_TASK_ROOT}
CMD [ "slack_notification.lambda_handler" ]