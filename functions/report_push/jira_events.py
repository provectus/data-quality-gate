from jira import JIRA

API_URL = os.getenv("JIRA_URL")
SECRET_NAME = os.getenv("SECRET_NAME", "ipa-develop-api-keys")
REGION_NAME = os.getenv("REGION_NAME")
SECRETS = get_secrets(REGION_NAME, SECRET_NAME)
API_USERNAME = SECRETS.get("JIRA_API_USERNAME")
API_PASSWORD = SECRETS.get("JIRA_API_PASSWORD")

options = {'server': API_URL}
jira = JIRA(options, basic_auth=(API_USERNAME, API_PASSWORD))


def open_bug(project_key: str, table_name: str, fail_step: str, description: str, replaced_allure_links):
    summary = "[DataQA][BUG][" + table_name + "] " + fail_step
    ticketExist = False
    issues = jira.search_issues('project=' + project_key, maxResults=None)
    for singleIssue in issues:
        if summary == str(singleIssue.fields.summary) and str(
                singleIssue.fields.status) == 'Open':
            print("Status is Open")
            ticketExist = True
            break
        if summary == str(singleIssue.fields.summary) and str(
                singleIssue.fields.status) != 'Open':
            print("Status is not open")
            ticketExist = True
            jira.transition_issue(singleIssue.key, transition='19')
            break
    if not ticketExist:
        create_new_bug(description, project_key, replaced_allure_links, summary)


def create_new_bug(description, project_key, replaced_allure_links, summary):
    print("Issue will be created soon")
    jira.create_issue(
        fields={
            "project": {"key": project_key},
            "issuetype": {"name": "Bug"},
            "summary": summary,
            "description": description + replaced_allure_links,
        }
    )
