from jira import JIRA

API_URL = os.getenv("JIRA_URL")
secret_name = os.getenv("SECRET_NAME", "ipa-develop-api-keys")
REGION_NAME = "us-west-2"
secrets = get_secrets(REGION_NAME, secret_name)
API_USERNAME = secrets.get("JIRA_API_USERNAME")
API_PASSWORD = secrets.get("JIRA_API_PASSWORD")

environment = os.environ['ENVIRONMENT']


options = {'server': API_URL}
jira = JIRA(options, basic_auth=(API_USERNAME, API_PASSWORD))


def get_all_bugs(project: str):
    got = 50
    total = 0
    while got == 50:
        issues = jira.search_issues('project=' + project, startAt=total)
        for singleIssue in issues:
            if str(singleIssue.fields.issuetype) == "Bug":
                print('{}: {}:{}'.format(singleIssue.key, singleIssue.fields.summary,
                                         singleIssue.fields.reporter.displayName))
        got = len(issues)
        total += got


def create_bug(project_key: str, table_name: str, fail_step: str, description: str, replaced_allure_links):
    summary = "[DataQA][BUG][" + table_name + "] " + fail_step
    print(summary)
    got = 50
    total = 0
    ticketExist = False
    while got == 50:
        issues = jira.search_issues('project=' + project_key, startAt=total)
        for singleIssue in issues:
            if str(singleIssue.fields.issuetype) == "Bug":
                if summary == str(singleIssue.fields.summary):
                    if str(singleIssue.fields.status) == 'Open':
                        print("Issue already exist and open")
                        ticketExist = True
                        break
                    if str(singleIssue.fields.status) == 'Done' or str(
                            singleIssue.fields.status) == 'Closed' or str(
                        singleIssue.fields.status) == 'Cancelled':
                        print("Issue closed, try to reopen")
                        print(singleIssue.key)
                        jira.transition_issue(singleIssue.key, transition='19')
                        ticketExist = True
                        break
        got = len(issues)
        total += got
    if not ticketExist:
        print("Issue not found, try to create new")
        jira.create_issue(
            fields={
                "project": {"key": project_key},
                "issuetype": {"name": "Bug"},
                "summary": summary,
                "description": description + replaced_allure_links,
            }
        )
