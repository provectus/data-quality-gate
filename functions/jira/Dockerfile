FROM public.ecr.aws/lambda/python:3.8

COPY jira/requirements.txt ./
RUN pip install -r requirements.txt

COPY jira/jira_events.py ./

CMD ["jira_events.jira_events_data"]
