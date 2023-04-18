from jira import JIRA
import os

API_URL = os.getenv("JIRA_URL")
API_USERNAME = os.getenv("DATAQA_JIRA_USERNAME")
API_PASSWORD = os.getenv("DATAQA_JIRA_PASSWORD")

options = {'server': API_URL}


def auth_in_jira():
    global jira
    jira = JIRA(options, basic_auth=(API_USERNAME, API_PASSWORD))


def open_bug(table_name: str, fail_step: str, description: str, replaced_allure_links, issues, jira_project_key):
    summary = f'[DataQA][BUG][{table_name}]{fail_step}'[:255]
    ticket_exist = False
    for single_issue in issues:
        if summary == str(single_issue.fields.summary) and str(
                single_issue.fields.status) == 'Open':
            ticket_exist = True
            break
        elif summary == str(single_issue.fields.summary) and str(
                single_issue.fields.status) != 'Open':
            ticket_exist = True
            print(f'Will be reopen bug with name[{summary}]')
            jira.transition_issue(single_issue.key, transition='Re-Open')
            break
    if not ticket_exist:
        create_new_bug(description, replaced_allure_links, summary, jira_project_key)
    return summary


def get_all_issues(jira_project_key):
    issues = jira.search_issues(f'project={jira_project_key}', maxResults=None)
    return issues


def create_new_bug(description, replaced_allure_links, summary, jira_project_key):
    print(f'Will be created bug with name[{summary}]')
    jira.create_issue(
        fields={
            "project": {"key": jira_project_key},
            "issuetype": {"name": "Bug"},
            "summary": summary,
            "description": description + replaced_allure_links,
        }
    )
