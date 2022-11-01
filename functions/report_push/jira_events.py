from jira import JIRA
import os

API_URL = os.getenv("JIRA_URL")
API_USERNAME = os.getenv("DATAQA_JIRA_USERNAME")
API_PASSWORD = os.getenv("DATAQA_JIRA_PASSWORD")

options = {'server': API_URL}


def auth_in_jira():
    global jira
    jira = JIRA(options, basic_auth=(API_USERNAME, API_PASSWORD))


def open_bug(table_name: str, fail_step: str, description: str, replaced_allure_links, issues):
    summary = f'[DataQA][BUG][{table_name}]{fail_step}'
    ticketExist = False
    for singleIssue in issues:
        if summary == str(singleIssue.fields.summary) and str(
                singleIssue.fields.status) == 'Open':
            ticketExist = True
            break
        elif summary == str(singleIssue.fields.summary) and str(
                singleIssue.fields.status) != 'Open':
            ticketExist = True
            print(f'Will be reopen bug with name[{summary}]')
            # jira.transition_issue(singleIssue.key, transition='19')
            break
    if not ticketExist:
        create_new_bug(description, replaced_allure_links, summary)


def get_all_issues(jira_project_key):
    issues = jira.search_issues(f'project={jira_project_key}', maxResults=None)
    return issues


def create_new_bug(description, replaced_allure_links, summary):
    print(f'Will be created bug with name[{summary}]')
    # jira.create_issue(
    #     fields={
    #         "project": {"key": project_key},
    #         "issuetype": {"name": "Bug"},
    #         "summary": summary,
    #         "description": description + replaced_allure_links,
    #     }
    # )
